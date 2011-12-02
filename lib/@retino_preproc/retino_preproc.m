classdef retino_preproc < handle
	%sensorPos -w sens -m -n -e -n CA01_STAN-pjolicoeur_20110630_01.ds
	properties (SetObservable = true)
		rs
		flat
	end
	methods
		function obj = retino_preproc(rs)
			obj.rs = rs;
			% Check if flattened MRI is available
			obj.proc_flat_vert();
			obj.proc_source_weight();
			obj.proc_default_corner_vert();
		end
		function obj = proc_flat_vert(obj)
			obj.flat.status = obj.get_status_flat(obj.rs);
			if isequal(obj.flat.status.file, 0)
				obj.save_flat_vert_from_ascii();
			end
			if isequal(obj.flat.status.var, 0)
				load(fullfile(obj.rs.dirs.berkeley, 'flatverts.mat'));
				obj.rs.lh.flat = lh.flat;
				obj.rs.rh.flat = rh.flat;
			end

		end
		function obj = proc_source_weight(obj)
			status = obj.get_status_source_weight(obj.rs);
			if isequal(status.file, 0)
				obj.save_source_weight();
			end
			if isequal(status.var, 0)
				load(fullfile(obj.rs.dirs.berkeley, 'fwd.mat'));
				obj.rs.fwd = fwd;
				setappdata(0, 'fwd',        fwd);
			end
		end
		function obj = proc_default_corner_vert(obj)
			status = obj.get_status_default_corner_vert(obj.rs);
			if isequal(status.file, 0)
				figure(171); close(171);
				rplot = retino_plotter;
				cfg.rs = obj.rs;
				cfg.aPatch = [];%rs.aPatch;
				rplot.cfg = cfg;
				rplot.plot_flat;
				set(171, 'Position', [2   100   704   333])
				rplot.plot_flat_rois();
				cfg.n_spokes = 4; cfg.n_rings = 4; cfg.type = input('type "patch" for rebuilding patch only : ', 's');
				obj.rs.fill_default_corner_vert(cfg);
			end
			if isequal(status.var, 0)
				load(fullfile(obj.rs.dirs.berkeley, 'default_corner_vert.mat'));
				obj.rs.default_corner_vert = default_corner_vert;
			end
		end

		function obj = save_flat_vert_from_ascii(obj)
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
					[filename, pathname]=uigetfile(fullfile(obj.rs.dirs.berkeley, 'lh*.asc'));
				elseif isequal(a_hemi{i_hemi}, 'R')
					[filename, pathname]=uigetfile(fullfile(obj.rs.dirs.berkeley, 'rh*.asc'));
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
			save(fullfile(obj.rs.dirs.berkeley, 'flatverts.mat'), 'lh', 'rh');
			obj.rs.lh.flat = lh.flat;
			obj.rs.rh.flat = rh.flat;
		end
		function obj = save_source_weight(obj)
			obj.rs.fill_source_weight();
			fwd = obj.rs.fwd;
			save(fullfile(obj.rs.dirs.berkeley, 'fwd.mat'), 'fwd');
		end
		function obj = save_default_corner_vert(obj)
			obj.rs.fill_source_weight();
			fwd = obj.rs.fwd;
			save(fullfile(obj.rs.dirs.berkeley, 'fwd.mat'), 'fwd');
		end
	end
	methods (Static)
		function status = get_status_flat(rs)
			status.var = ~(isempty(rs.lh) || ~isempty(rs.rh) );
			status.file = exist(fullfile(rs.dirs.berkeley, 'flatverts.mat'), 'file');
		end
		function status = get_status_source_weight(rs)
			status.var = isfield(rs.fwd.src, 'source_weight');
			status.file = exist(fullfile(rs.dirs.berkeley, 'fwd.mat'), 'file');
		end
		function status = get_status_default_corner_vert(rs)
			status.var = isfield(rs, 'default_corner_vert');
			status.file = exist(fullfile(rs.dirs.berkeley, 'default_corner_vert.mat'), 'file');
		end
	end
end

