classdef retino_preproc < handle
	%sensorPos -w sens -m -n -e -n CA01_STAN-pjolicoeur_20110630_01.ds
% 	properties (SetObservable = true)
    properties
		rs
		flat
	end
	methods
		function o = retino_preproc(rs)
			o.rs = rs;
			% Check if flattened MRI is available
            if isfield_recursive(rs, 'options', 'fmri', 'toggle') && rs.options.fmri.toggle
                o.proc_fmri(isfield_recursive(rs, 'options', 'fmri', 'reset') && rs.options.fmri.reset);
            end
			o.proc_flat_vert();
			o.proc_source_weight();
% 			o.proc_default_corner_vert();
        end
		function o = proc_flat_vert(o)
			o.flat.status = o.get_status_flat(o.rs);
			if isequal(o.flat.status.file, 0)
				o.save_flat_vert_from_ascii();
			end
			if isequal(o.flat.status.var, 0)
				load(fullfile(o.rs.dirs.berkeley, 'flatverts.mat'));
				o.rs.lh.flat = lh.flat;
				o.rs.rh.flat = rh.flat;
			end

		end
		function o = proc_source_weight(o)
			status = o.get_status_source_weight(o.rs);
			if isequal(status.file, 0)
				o.save_source_weight();
			end
			if isequal(status.var, 0)
				load(fullfile(o.rs.dirs.berkeley, 'fwd.mat'));
				o.rs.fwd = fwd;
				setappdata(0, 'fwd',        fwd);
			end
		end
		function o = proc_default_corner_vert(o)
			status = o.get_status_default_corner_vert(o.rs);
			if isequal(status.file, 0)
				figure(o.rs.h.main.fig); close(o.rs.h.main.fig);
				rplot = retino_plotter;
				cfg.rs = o.rs;
				cfg.aPatch = [];%rs.aPatch;
				rplot.cfg = cfg;
                rplot.plot_flat;
                rplot.plot_flat_retino;
                try, set(o.rs.h.retino.all, 'visible', 'off'); end
				set(o.cfg.h_main, 'Position', [2   100   704   333])
				rplot.plot_flat_rois();
				cfg.n_spokes = 4; cfg.n_rings = 4; cfg.type = input('type "patch" for rebuilding patch only : ', 's');
				o.rs.fill_default_corner_vert(cfg);
			end
			if isequal(status.var, 0)
				load(fullfile(o.rs.dirs.berkeley, 'default_corner_vert.mat'));
				o.rs.default_corner_vert = default_corner_vert;
			end
        end
        function o = proc_fmri(o, reset_flag)
            disp('Processing fMRI from mrVista');
			status = o.get_status_fmri(o.rs);
			if isequal(status.file, 0) || reset_flag
				fmri = retino_fmri(o.rs);
                fmri = fmri.load_from_mrv();
                fmri = fmri.make_retino_data();
                fmri_data = fmri.save_prop();
                save(fullfile(o.rs.dirs.berkeley, 'fmri.mat'), 'fmri_data');
			end
			if isequal(status.var, 0)
				load(fullfile(o.rs.dirs.berkeley, 'fmri.mat'));
                fmri = retino_fmri(o.rs);
                fmri.load_prop(fmri_data);
				o.rs.fmri = fmri;
                o.rs.fmri.make_retino_data();
			end
        end
		function o = save_flat_vert_from_ascii(o)
			a_hemi = {'L' 'R'};
			for i_hemi = 1:numel(a_hemi)
				%          Flatten occipital patch
				%          tksurfer $subjectid lh inflated
				%          mris_flatten -w 10 lh.occip.patch.3d lh.occip.flat.patch.3d
				%          mris_flatten -w 10 rh.occip.3d.small rh.occip.flat.small
				%          Convert the flattened occipital patch to ascii format
				%          mris_convert -p lh.occip.flat.patch.3d l.asc
				%          mris_convert -p rh.occip.flat.small rh.occip.flat.small.asc
				if isequal(a_hemi{i_hemi}, 'L')
					[filename, pathname]=uigetfile(fullfile(o.rs.dirs.berkeley, 'lh*.asc'));
				elseif isequal(a_hemi{i_hemi}, 'R')
					[filename, pathname]=uigetfile(fullfile(o.rs.dirs.berkeley, 'rh*.asc'));
				else
					error('Unknown hemisphere');
				end
				fullpath = fullfile(pathname, filename);
				fid = fopen(fullpath, 'r');
				fgetl(fid);
				buff=fgetl(fid);
				vert_info=sscanf(buff, '%f %f', [1, inf]);
				n_vert = vert_info(1);
				n_tri  = vert_info(2);
				count = 1;
				for i_vert = 1:n_vert
					buff=fgetl(fid);
					vert_ind=sscanf(buff, '%d vno=%d', [1, inf]);
					buff=fgetl(fid);
					vert_coord=sscanf(buff, '%f %f %f', [1, inf]);
					flat.vert(count,:) = [vert_ind(2)+1 vert_coord];
					count = count + 1;
				end
				vert_full = NaN(max(flat.vert(:,1)), size(flat.vert,2));
				for i_vert = 1:length(flat.vert)
					vert_full(flat.vert(i_vert,1),:) = flat.vert(i_vert,:);
				end
				flat.vert_full = vert_full;
				%          2
				%          count = 1;
				%          tris = []
				%          for i_vert = 1:n_tri
				%             buff=fgetl(fid);
				%             vert_ind=sscanf(buff, '%d', [1, inf]);
				%             buff=fgetl(fid);
				%             tris(count,:) = sscanf(buff, '%d %d %d', [1, inf]) + 1;
				%             count = count + 1;
				%          end
				%          flat.tris = tris;
				%          fclose(fid);
				%          3
				if isequal(a_hemi{i_hemi}, 'L')
					lh.flat = flat;
				elseif isequal(a_hemi{i_hemi}, 'R')
					rh.flat = flat;
				end
			end
			save(fullfile(o.rs.dirs.berkeley, 'flatverts.mat'), 'lh', 'rh');
			o.rs.lh.flat = lh.flat;
			o.rs.rh.flat = rh.flat;
		end
		function o = save_source_weight(o)
			o.rs.fill_source_weight();
			fwd = o.rs.fwd;
			save(fullfile(o.rs.dirs.berkeley, 'fwd.mat'), 'fwd');
        end
	end
	methods (Static)
		function status = get_status_flat(rs)
			status.var = ~isempty(rs.lh) && ~isempty(rs.rh) ;
			status.file = exist(fullfile(rs.dirs.berkeley, 'flatverts.mat'), 'file');
		end
		function status = get_status_source_weight(rs)
% 			status.var = isfield(rs.fwd.src, 'source_weight');
            status.var = isfield_recursive(rs, 'source_weight') && ~isempty(rs.source_weight);
			status.file = exist(fullfile(rs.dirs.berkeley, 'fwd.mat'), 'file');
		end
		function status = get_status_default_corner_vert(rs)
			status.var = isfield_recursive(rs, 'default_corner_vert') && ~isempty(rs.default_corner_vert);
			status.file = exist(fullfile(rs.dirs.berkeley, 'default_corner_vert.mat'), 'file');
        end
        function status = get_status_fmri(rs)
			status.var = isfield_recursive(rs, 'fmri') && ~isempty(rs.fmri);
			status.file = exist(fullfile(rs.dirs.berkeley, 'fmri.mat'), 'file');
        end
        function status = get_status_curveset(rs)
			status.var = isfield_recursive(rs, 'fmri') && ~isempty(rs.fmri);
			status.file = exist(fullfile(rs.dirs.berkeley, 'fmri.mat'), 'file');
		end
	end
end

