classdef retino_session < handle
    properties (SetObservable = true)
        subj_id
        dirs
        rois
        
        retinoPatch
        design
        
        a_patch
        a_source
        a_kern
        a_chan
        a_time
        default_corner_vert
        
        fwd
        sph_fwd
        data
        ctf
        ctf_emp
        
        meg_chan = 1:272;
        eeg_chan = 273:327;
        
        h
        a
        b
        
        sim
        patch_source_index
        pt
        
        lh
        rh
        
        thisVert
    end
    
    methods
			function obj = RetinoSession(obj)
				% RetinoSession Constructor
				% Define the nodes and nodesAll windows for inflated lh
				%             fv = [];
				%             [fv.vertices,fv.faces]=mne_read_surface('/raid/MRI/anatomy/FREESURFER_SUBS/DK_fs4/surf/lh.inflated');
				%             obj.lh.fv = fv;
				%             obj.lh.nodesAll = [(1:size(fv.vertices,1))' fv.vertices(:,1) fv.vertices(:,2) fv.vertices(:,3)];
				%             %          obj.lh.iOcci = obj.lh.nodesAll(:,2)>=.0095 & obj.lh.nodesAll(:,3)<=-.09 & obj.lh.nodesAll(:,4)<=-.025;
				%             obj.lh.iOcci = obj.lh.nodesAll(:,2)>=0 & obj.lh.nodesAll(:,3)<=-.07 & obj.lh.nodesAll(:,4)<=-0.015;
				%             obj.lh.nodes = obj.lh.nodesAll(obj.lh.iOcci,:);
				%             faces = unique(sort([fv.faces(:,1:2);fv.faces(:,2:3)],2),'rows');
				%             k = faces((ismember(faces(:,1),obj.lh.nodes(:,1))) | (ismember(faces(:,2),obj.lh.nodes(:,1))),:);
				%             faces = unique(k,'rows');         nSeg = size(faces,1);         obj.lh.segments = [(1:nSeg)' faces];
				%             
				%             fv = [];
				%             % Define the nodes and nodesAll windows for inflated rh
				%             [fv.vertices,fv.faces]=mne_read_surface('/raid/MRI/anatomy/FREESURFER_SUBS/DK_fs4/surf/rh.inflated');
				%             obj.rh.nodesAll = [(1:size(fv.vertices,1))' fv.vertices(:,1) fv.vertices(:,2) fv.vertices(:,3)];
				%             obj.rh.iOcci = obj.rh.nodesAll(:,2)<=0 & obj.rh.nodesAll(:,3)<=-.07 & obj.rh.nodesAll(:,4)<=-0.015;
				%             %          obj.rh.iOcci = obj.rh.nodesAll(:,2)<=-.015 & obj.rh.nodesAll(:,3)<=-.08 & obj.rh.nodesAll(:,4)<=-.025;
				%             obj.rh.nodes = obj.rh.nodesAll(obj.rh.iOcci,:);
				%             faces = unique(sort([fv.faces(:,1:2);fv.faces(:,2:3)],2),'rows');
				%             k = faces((ismember(faces(:,1),obj.rh.nodes(:,1))) | (ismember(faces(:,2),obj.rh.nodes(:,1))),:);
				%             faces = unique(k,'rows');         nSeg = size(faces,1);         obj.rh.segments = [(1:nSeg)' faces];
				%             
				%             fv = [];
				%             [fv.vertex,fv.face]=mne_read_surface('/raid/MRI/anatomy/FREESURFER_SUBS/DK_fs4/surf/lh.midgray');
				%             obj.lh.midgray.fv = fv;
				%             
				%             fv = [];
				%             [fv.vertex,fv.face]=mne_read_surface('/raid/MRI/anatomy/FREESURFER_SUBS/DK_fs4/surf/rh.midgray');
				%             obj.rh.midgray.fv = fv;
			end
			function init_session_patch(obj)
				n_source = numel(obj.a_source);
				c1 = jet(32*n_source); c{1} = c1(1:32,:); %c = c(randperm(16),:);
				c2 = jet(32*n_source); c{2} = c2(33:end,:);
				c3 = jet(32*n_source); c{3} = c3(65:end,:);
				for i_source = 1:length(obj.a_source)
					ai_source = obj.a_source(i_source);
					fprintf('Building >> Source %g ::: Patch ', i_source);
					for i_patch = 1:length(obj.a_patch)
						ai_patch = obj.a_patch(i_patch);

						rp(ai_source, ai_patch) = retino_patch;
						rp(ai_source, ai_patch).session = obj;
						t.rp = rp(ai_source, ai_patch);
						% Finds in the design matrix the roi file list corresponding to (iPatch, iSource)
						t.rp.ind      = ai_patch;
						t.rp.area     = ai_source;
						t.rp.hiResCornerVert             = obj.default_corner_vert.patch(ai_source, ai_patch).hiResCornerVert;
						t.rp.hemi                        = obj.default_corner_vert.patch(ai_source, ai_patch).hemi;
						try
							t.rp.faceColor = c{i_source}(ai_patch,:);
							t.rp.edgeColor = c{i_source}(ai_patch,:);
						catch
							t.rp.faceColor = [rand rand rand];
							t.rp.edgeColor = [rand rand rand];
						end
						t.rp.fill_flat_vert();
						t.rp.fill_surf_from_corner();
						t.rp.calculate_forward_hi();
						t.rp.calculate_forward_hi_jitter_norm();
						%       t.rp.calculate_forward_hi_true(fwdtrue);
						fprintf('%02g ', i_patch);
					end
					fprintf(' ::: %0.1g sec \n', toc);
				end
				obj.retinoPatch = rp;
				obj.fill_patch_source_index();
				obj.fill_pt();
			end
			function update_timefcn_fig(obj)
				if isfield(obj.h,'timefcn')
					h1 = obj.h.ctf;
					data1 = obj.ctf;
					for i_data = size(data1,1)
						set(h1(i_data), 'YData', data1(i_data,:));
					end
					h2 = obj.h.ctf_emp;
					data2 = obj.ctf_emp;
					for i_data = size(data2,1)
						set(h2(i_data), 'YData', data2(i_data,:));
					end
				end
			end
			function obj = session_eval(obj, func_name)
				for i_patch = 1:length(obj.a_patch)
					ai_patch = obj.a_patch(i_patch);
					for i_source = 1:length(obj.a_source)
						ai_source = obj.a_source(i_source);
						t.rp = obj.retinoPatch(ai_source, ai_patch);
						eval(sprintf('t.rp.%s();', func_name));
					end
				end
			end
			function out = calculate_common_time_fcn(obj, a_patch, chanType)
				avgdata = obj.data.mean;
				switch chanType
					case 'meg'
						a_chan = obj.meg_chan;
					case 'eeg'
						a_chan = obj.eeg_chan;
					case 'meeg'
						a_chan = [obj.meg_chan obj.eeg_chan];
					otherwise
						error('Must define channel type');
				end
				n_source = 2; %% This should be taken out to script/session settings for generality
				nAllChan = length([obj.meg_chan obj.eeg_chan]);
				for i_patch = 1:length(a_patch)
					aEP_F = (1:nAllChan)+(i_patch-1)*nAllChan;
					for i_source = 1:n_source
						ai_patch = obj.find_patch_source_index(a_patch(i_patch), i_source);

						t.sign = 1;
						if (i_source == 2) && ~isempty(find([2 6 7 9 10 14 15 28 29 21 22 23 27 29 30 31] == a_patch(i_patch)))
							%                   if (i_source == 2) && ~isempty(find([2 3 4 13 17 20 25 26 28 32] == a_patch(i_patch)))
							t.sign = -1;
						end

						F.meeg(aEP_F,i_source) = t.sign*obj.retinoPatch(ai_patch).F.mean.norm(1:nAllChan);
					end
				end
				% Rescale M/EEG signals and forward matrix
				% Here I found that ME_Factor of 1e7 to be good
				aEP_data = []; aEP_F = []; aEP_F_meg = []; aEP_data_meg = [];
				for i_patch = 1:length(a_patch)
					aEP_data = [aEP_data (a_chan)+(find(obj.a_patch==a_patch(i_patch))-1)*nAllChan];
					%             aEP_eeg_data = [aEP_eeg_data (obj.eeg_chan)+(find(obj.a_patch==a_patch(i_patch))-1)*nAllChan];
					aEP_data_meg = [aEP_data_meg (obj.meg_chan)+(find(obj.a_patch==a_patch(i_patch))-1)*nAllChan];
					aEP_F = [aEP_F (a_chan)+(i_patch-1)*nAllChan];
					aEP_F_meg = [aEP_F_meg obj.meg_chan+(i_patch-1)*nAllChan];
				end
				ME_Factor = [1*1e-7];
				avgdata(aEP_data_meg,:) = avgdata(aEP_data_meg,:)/ME_Factor;
				t.avgdata_rescaled   = avgdata(aEP_data,:);
				F.meeg(aEP_F_meg,:)  = F.meeg(aEP_F_meg,:)/ME_Factor;
				t.F.meeg_rescaled = F.meeg(aEP_F,:);
				Tprime_MEEG = (t.F.meeg_rescaled'*t.F.meeg_rescaled)\t.F.meeg_rescaled'*t.avgdata_rescaled; % for 1 source only, 1st iternation
				out=Tprime_MEEG;
			end
			function out = calculate_svd(obj, a_patch, chanType)
				avgdata = obj.data.mean;
				data_ind = obj.select_data_ind(a_patch, chanType);
				[obj.ctf.svd.u, obj.ctf.svd.s, obj.ctf.svd.t]=svd(avgdata(data_ind,:));
				obj.ctf.svd.a_patch = a_patch;
				out = 1;
			end
			function out = find_patch_2_roi_index(obj, i_patch, i_source)
				out = find(cellfun(@(x) x==i_patch,obj.design.patch2roi(:,1)) & cellfun(@(x) x==i_source,obj.design.patch2roi(:,2)));
			end
			function out = find_patch_source_index(obj, i_patch, i_source)
				out = obj.patch_source_index(i_patch, i_source);
				error('Should not need this any more');
			end
			function out = select_data_ind(obj, a_patch, chanType)
				aEP_data = []; nAllChan = length([obj.meg_chan obj.eeg_chan]);
				switch chanType
					case 'meg'
						a_chan = obj.meg_chan;
					case 'eeg'
						a_chan = obj.eeg_chan;
					case 'meeg'
						a_chan = [obj.meg_chan obj.eeg_chan];
					otherwise
						error('Must define channel type');
				end
				for i_patch = 1:length(a_patch)
					aEP_data = [aEP_data (a_chan)+(find(obj.a_patch==a_patch(i_patch))-1)*nAllChan];
				end
				out = aEP_data;
			end
			function out = select_chan(obj, chanType, iRetinoPatch)
				switch chanType
					case 'meg'
						a_chan = obj.meg_chan;
					case 'eeg'
						a_chan = obj.eeg_chan;
					case 'meeg'
						a_chan = [obj.meg_chan obj.eeg_chan];
					otherwise
						error('Must define channel type');
				end
				if nargin < 3
					iRetinoPatch = 1;
				end
				nChan = size(a_chan,2);
				out = (1:nChan)+(iRetinoPatch-1)*nChan;
			end
			function obj = fill_session_patch_flat_vert(obj)
				for iSessPatch = 1:size(obj.retinoPatch,2)
					obj.retinoPatch(iSessPatch).fill_flat_vert();
				end
			end
			function obj = fill_session_patch_Vdata(obj, i_kern)
				if ~exist('i_kern', 'var')
					i_kern = obj.a_kern;
				end
				for i_patch = 1:length(obj.a_patch)
					ai_patch = obj.a_patch(i_patch);
					for i_source = 1:length(obj.a_source)
						ai_source = obj.a_source(i_source);
						t.rp = obj.retinoPatch(ai_source, ai_patch); 
						t.rp.fill_Vdata(obj.data.mean(:,:,i_kern,:));
					end
				end

			end
			function obj = fill_session_patch_timefcn(obj)
				for i_patch = 1:length(obj.a_patch)
					ai_patch = obj.a_patch(i_patch);
					Fall = [];
					Vall = [];
					for i_source = 1:length(obj.a_source)
						ai_source = obj.a_source(i_source);
						t.rp = obj.retinoPatch(ai_source, ai_patch);
						t.F = t.rp.F.mean.norm;
						Fall = [Fall t.F(obj.a_chan)];
						Vall = obj.concat_V_kern(t.rp);
					end
					thisPatch.timefcn = Fall\Vall;
					for i_source = obj.a_source
						ai_source = obj.a_source(i_source);
						t.rp = obj.retinoPatch(ai_source, ai_patch);
						t.rp.timefcn = thisPatch.timefcn(i_source,:);
					end
				end
			end
			function obj = fill_session_patch_timefcn_emp(obj)
				for i_patch = 1:length(obj.a_patch)
					ai_patch = obj.a_patch(i_patch);
					Fall = [];
					Vall = [];
					for i_source = 1:length(obj.a_source)
						ai_source = obj.a_source(i_source);
						t.rp = obj.retinoPatch(ai_source, ai_patch);
						t.F = t.rp.Femp.mean.norm;
						Fall = [Fall t.F(obj.a_chan)];
						Vall = obj.concat_V_kern(t.rp);
					end
					thisPatch.timefcn = Fall\Vall;
					for i_source = obj.a_source
						ai_source = obj.a_source(i_source);
						t.rp = obj.retinoPatch(ai_source, ai_patch);
						t.rp.timefcn_emp = thisPatch.timefcn(i_source,:);
					end
				end
			end
			function obj = fill_ctf(obj, a_patch, chanType)
				V = []; F = [];
				for i_patch = 1:length(obj.a_patch)
					ai_patch = obj.a_patch(i_patch);
					rowInd = select_chan(obj, chanType, i_patch);
					for i_source = 1:length(obj.a_source)
						ai_source = obj.a_source(i_source);
						t.rp = obj.retinoPatch(ai_source, ai_patch);

						t.V = obj.concat_V_kern(t.rp);
						V(rowInd,:) = t.V;
						F(rowInd, i_source) = t.rp.F.mean.norm(obj.a_chan, :);
					end
				end
				obj.ctf = F\V;
			end
			function obj = fill_ctf_Femp(obj, a_patch, chanType)
				V = []; F = [];
				for i_patch = 1:length(obj.a_patch)
					ai_patch = obj.a_patch(i_patch);
					rowInd = select_chan(obj, chanType, i_patch);
					for i_source = 1:length(obj.a_source)
						ai_source = obj.a_source(i_source);
						t.rp = obj.retinoPatch(ai_source, ai_patch);

						V(rowInd,:) = obj.concat_V_kern(t.rp);
						F(rowInd, i_source) = t.rp.Femp.mean.norm(obj.a_chan, :);
					end
				end
				obj.ctf_emp = F\V;
			end
			function obj = fill_Femp(obj, a_patch, chanType)
				for i_patch = 1:length(obj.a_patch)
					ai_patch = obj.a_patch(i_patch);
					t.rp = obj.retinoPatch(1, ai_patch); % V's are all the same regardless of ai_source
					rowInd = select_chan(obj, chanType, i_patch);
					V(rowInd,:) = obj.concat_V_kern(t.rp);
				end
				Femp = V/obj.ctf;
				for i_patch = 1:length(obj.a_patch)
					ai_patch = obj.a_patch(i_patch);
					for i_source = 1:length(obj.a_source)
						ai_source = obj.a_source(i_source);
						t.rp = obj.retinoPatch(ai_source, ai_patch);
						rowInd = select_chan(obj, chanType, i_patch);
						t.rp.Femp.mean.norm = Femp(rowInd,i_source);
					end
				end
			end
			function obj = jitter_session_pt_corner(obj)
				pt = obj.pt;
				for i_pt = 1:length(pt)
					pt_i = pt(i_pt);
					for i_patch = 1
						ai_patch = pt_i.patch(i_patch); % Does not matter which patch I choose
						ai_corner = pt_i.corner_ind(i_patch);
						t.rp = obj.retinoPatch(ai_patch);
						neighbors = t.rp.get_neighbor_vert_range(ai_corner, 5);
						i_perm = randi(size(neighbors)-1)+1;
					end
					for i_patch = 1:length(pt_i.patch)
						ai_patch = pt_i.patch(i_patch); % Does not matter which patch I choose
						ai_corner = pt_i.corner_ind(i_patch);
						t.rp = obj.retinoPatch(ai_patch);
						t.rp.hiResCornerVert(ai_corner) = neighbors(i_perm);
					end
				end
			end
			function obj = jitter_session_pt_corner_dir(obj,vect)
				pt = obj.pt;
				for i_pt = 1:length(pt)
					pt_i = pt(i_pt);
					hemi = pt_i.hemi;
					switch hemi
						case 'L'
							vert_full = obj.lh.flat.vert_full;
						case 'R'
							vert_full = obj.rh.flat.vert_full;
						otherwise
							error('');
					end
					for i_patch = 1
						ai_patch  = pt_i.ind(1);
						ai_source = pt_i.area(1);
						ai_corner = pt_i.corner_ind(1);

						t.rp = obj.retinoPatch(ai_source, ai_patch);
						t.hiResCornerVert = t.rp.hiResCornerVert(ai_corner);

						t.vert = vert_full(t.hiResCornerVert,2:4);
						next.vert = t.vert + vect;
						[a,b]=nearpoints(vert_full(:,2:4)', next.vert');
						b(b==0) = inf;
						[a, b]=min(b);
						next.hiResCornerVert = b;
					end
					for i_patch = 1:length(pt_i.ind)
						ai_source = pt_i.area(i_patch);
						ai_patch = pt_i.ind(i_patch); % Does not matter which patch I choose
						ai_corner = pt_i.corner_ind(i_patch);

						t.rp = obj.retinoPatch(ai_source, ai_patch);
						t.rp.hiResCornerVert(ai_corner) = next.hiResCornerVert;
					end
				end
			end
			function obj = interpolate_fwd(obj)
				l_rr = obj.fwd.source_rr(1:length(obj.fwd.src(1).vertno),:);
				r_rr = obj.fwd.source_rr((obj.fwd.src(1).nuse+1):end,:);
				obj.a=nearpoints(obj.fwd.src(1).rr',l_rr');
				obj.b=nearpoints(obj.fwd.src(2).rr',r_rr');
			end
			function obj = fill_patch_source_index(obj)
				rp = obj.retinoPatch;
				for i = 1:length(rp)
					a(rp(i).ind, rp(i).area) = i;
				end
				obj.patch_source_index = a;
			end
			function obj = fill_pt(obj)
				i_rp = 0;
				for i_patch = 1:length(obj.a_patch)
					ai_patch = obj.a_patch(i_patch);
					for i_source = 1:length(obj.a_source)
						ai_source = obj.a_source(i_source);
						i_rp = i_rp + 1;
						t.rp = obj.retinoPatch(ai_source, ai_patch);
						hemi(1:4, i_rp) = t.rp.hemi;
						cv(:,i_rp) = t.rp.hiResCornerVert;
					end
				end
				hemi = hemi(:);
				cv = cv(:);
				[asdf_vert, tab] = unique(cv);
				asdf_hemi = hemi(tab);
				for i = 1:length(asdf_vert)
					pt(i).vert = asdf_vert(i);
					pt(i).hemi = asdf_hemi(i);
					pt(i).patch = [];
				end
				for i_pt = 1:length(pt)
					i_rp = 0;
					for i_patch = 1:length(obj.a_patch)
						ai_patch = obj.a_patch(i_patch);
						for i_source = 1:length(obj.a_source)
							ai_source = obj.a_source(i_source);
							i_rp = i_rp + 1;
							t.rp = obj.retinoPatch(ai_source, ai_patch);


							[asdf, tab] = ismember(pt(i_pt).vert, t.rp.hiResCornerVert);
							if ~isempty(find(tab))
								i_patch = length(pt(i_pt).patch)+1;
								pt(i_pt).patch(i_patch) = i_rp;
								pt(i_pt).area(i_patch) = ai_source;
								pt(i_pt).ind(i_patch)  = ai_patch;
								pt(i_pt).corner_ind(i_patch) = tab;
							end
						end
					end
				end
				obj.pt = pt;
			end
			function obj = fill_source_weight(obj)
				for i_hemi = 1:2
					src=obj.fwd.src(i_hemi);
					tris = src.tris;
					rr = src.rr;
					tic
					hemi_weight = zeros(size(rr,1),1);
					for i_tris = 1:length(tris)
						i_vert = tris(i_tris,:);
						a_rr = rr(tris(i_tris,:),:);
						v1=a_rr(1,:)-a_rr(2,:);
						v2=a_rr(1,:)-a_rr(3,:);
						%                     v3=a_rr(2,:)-a_rr(3,:);
						hemi_weight(i_vert)=norm(cross(v1,v2)/2/3)+hemi_weight(i_vert);
						if mod(i_tris,10000) == 0, disp(sprintf('%g of %g', i_tris, length(tris))); end
					end
					obj.fwd.src(i_hemi).source_weight = hemi_weight;
				end
			end
			function fill_default_corner_vert(rs, cfg)
				rois = rs.rois.data;
				n_spoke    = rs.design.n_spoke;
				m           = rs.design.n_ring;
				n           = n_spoke/4;
				default_corner_vert = rs.default_corner_vert;
				default_corner_vert.patch = [];
				for i_rois = 1:numel(rois)
					fprintf('%s  ', rois{i_rois});
					this.roi_name = explode('-', rois{i_rois});
					hemi = this.roi_name{2};
					area = str2double(this.roi_name{1}(2));
					dorsal_ventral = this.roi_name{1}(3);
					if isequal(hemi, 'L')
						vert_full = rs.lh.flat.vert_full;
						if isequal(dorsal_ventral, 'D')
							offset = 0;
						else
							offset = 1*n;
						end
					elseif isequal(hemi, 'R')
						vert_full = rs.rh.flat.vert_full;
						if isequal(dorsal_ventral, 'D')
							offset = 2*n;
						else
							offset = 3*n;
						end
					else
						error('unknown hemisphere');
					end

					if isequal(cfg.type, 'patch')
						rs.thisVert.new_vert.hiResCornerVert =rs.default_corner_vert.roi(i_rois).hiResCornerVert;
					else
						for i_corner = 1:4
							rs.thisVert.button_state = 'on';
							setappdata(171,'keyChoice', 'add_new_patch')
							rs.thisVert.new_vert.i_corner = i_corner;
							figure(171);
							uiwait(171);
							fprintf('%s:%g - ', rois{i_rois}, i_corner);
						end
					end

					p1 = rs.thisVert.new_vert.hiResCornerVert(1);
					p2 = rs.thisVert.new_vert.hiResCornerVert(2);
					p3 = rs.thisVert.new_vert.hiResCornerVert(3);
					p4 = rs.thisVert.new_vert.hiResCornerVert(4);

					default_corner_vert.roi(i_rois).name = rois{i_rois};
					default_corner_vert.roi(i_rois).hiResCornerVert = rs.thisVert.new_vert.hiResCornerVert;

					for i_u = 1:n
						for i_v = 1:m
							lat_ind(i_v, i_u) = i_u + (i_v-1)*n_spoke;
						end
					end
					lat_ind = lat_ind + offset;
					if mod(area,2)==0
						lat_ind = fliplr(lat_ind);
					end

					pos1 = vert_full(p1,2:end);
					pos2 = vert_full(p2,2:end);
					pos3 = vert_full(p3,2:end);
					pos4 = vert_full(p4,2:end);

					try delete(h.previous_roi); end
					roi_x = [pos1(1) pos2(1) pos3(1) pos4(1) pos1(1)];
					roi_y = [pos1(2) pos2(2) pos3(2) pos4(2) pos1(2)];
					h.previous_roi = plot(roi_x, roi_y, 'ro-', 'LineWidth', 1.5', 'MarkerSize', 10, 'MarkerFaceColor', 'b');
					u12 = pos2-pos1;
					u43 = pos3-pos4;

					for i_u = 0:n
						lat{1, i_u+1} = pos1 + u12*i_u/n;
					end

					for i_u = 0:n
						lat{m+1, i_u+1} = pos4 + u43*i_u/n;
					end

					for i_u = 0:n
						for i_v = 1:m-1
							lat{i_v+1, i_u+1} = lat{1, i_u+1} + (lat{m+1, i_u+1}-lat{1, i_u+1})*i_v/m;
						end
					end
					for i_u = 0:n
						for i_v = 0:m
							this.pos = lat{i_v+1, i_u+1};
							[a,b]=nearpoints(vert_full(:,2:4)', this.pos');
							b(b==0) = inf;
							[a, b]=min(b);
							hiResCornerVert(i_v+1, i_u+1) = b;
						end
					end
					for i_u = 1:n
						for i_v = 1:m
							t.hiResCornerVert(1) = hiResCornerVert(i_v, i_u);
							t.hiResCornerVert(2) = hiResCornerVert(i_v, i_u+1);
							t.hiResCornerVert(3) = hiResCornerVert(i_v+1, i_u+1);
							t.hiResCornerVert(4) = hiResCornerVert(i_v+1, i_u);
							default_corner_vert.patch(area,lat_ind(i_v, i_u)).name = rois{i_rois};
							default_corner_vert.patch(area,lat_ind(i_v, i_u)).hiResCornerVert = t.hiResCornerVert;
							default_corner_vert.patch(area,lat_ind(i_v, i_u)).hemi            = hemi;
						end
					end
				end
				rs.default_corner_vert = default_corner_vert;
				save(fullfile(rs.dirs.berkeley, 'default_corner_vert.mat'), 'default_corner_vert');
				try delete(h.previous_roi); end
				fprintf('\n');
			end
		end
		methods (Static)
			function V = concat_V_kern(rp)
				V = [];
				for i_kern = 1:length(rp.session.a_kern)
					ai_kern = rp.session.a_kern(i_kern);
					%              V = [V squeeze(rp.Vdata(rp.session.a_chan, ai_kern,:))];
					V = [V squeeze(rp.Vdata(rp.session.a_chan, i_kern,:))];
				end    
			end
			function timefcn_handler(src, event)
				obj = event.AffectedObject;
				obj.update_timefcn_fig;
			end
		end
	end

