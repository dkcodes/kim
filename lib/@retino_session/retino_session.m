classdef retino_session < handle
    properties (SetObservable = true)
        subj_id
        retinoPatch

        a_patch
        a_source
        a_kern
        a_chan
        a_time
        
        dirs
        rois
        design
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
        pt
        
        lh
        rh
        
        thisVert
    end
    
    methods
			function obj =  retino_session()
				%	  Define the nodes and nodesAll windows for inflated lh
				% fv = [];
				% [fv.vertices,fv.faces]=mne_read_surface('/raid/MRI/anatomy/FREESURFER_SUBS/DK_fs4/surf/lh.inflated');
				% obj.lh.fv = fv;
				% obj.lh.nodesAll = [(1:size(fv.vertices,1))' fv.vertices(:,1) fv.vertices(:,2) fv.vertices(:,3)];
				%          obj.lh.iOcci = obj.lh.nodesAll(:,2)>=.0095 & obj.lh.nodesAll(:,3)<=-.09 & obj.lh.nodesAll(:,4)<=-.025;
				% obj.lh.iOcci = obj.lh.nodesAll(:,2)>=0 & obj.lh.nodesAll(:,3)<=-.07 & obj.lh.nodesAll(:,4)<=-0.015;
				% obj.lh.nodes = obj.lh.nodesAll(obj.lh.iOcci,:);
				% faces = unique(sort([fv.faces(:,1:2);fv.faces(:,2:3)],2),'rows');
				% k = faces((ismember(faces(:,1),obj.lh.nodes(:,1))) | (ismember(faces(:,2),obj.lh.nodes(:,1))),:);
				% faces = unique(k,'rows');         nSeg = size(faces,1);         obj.lh.segments = [(1:nSeg)' faces];

				% fv = [];
				% Define the nodes and nodesAll windows for inflated rh
				% [fv.vertices,fv.faces]=mne_read_surface('/raid/MRI/anatomy/FREESURFER_SUBS/DK_fs4/surf/rh.inflated');
				% obj.rh.nodesAll = [(1:size(fv.vertices,1))' fv.vertices(:,1) fv.vertices(:,2) fv.vertices(:,3)];
				% obj.rh.iOcci = obj.rh.nodesAll(:,2)<=0 & obj.rh.nodesAll(:,3)<=-.07 & obj.rh.nodesAll(:,4)<=-0.015;
				%          obj.rh.iOcci = obj.rh.nodesAll(:,2)<=-.015 & obj.rh.nodesAll(:,3)<=-.08 & obj.rh.nodesAll(:,4)<=-.025;
				% obj.rh.nodes = obj.rh.nodesAll(obj.rh.iOcci,:);
				% faces = unique(sort([fv.faces(:,1:2);fv.faces(:,2:3)],2),'rows');
				% k = faces((ismember(faces(:,1),obj.rh.nodes(:,1))) | (ismember(faces(:,2),obj.rh.nodes(:,1))),:);
				% faces = unique(k,'rows');         nSeg = size(faces,1);         obj.rh.segments = [(1:nSeg)' faces];
			end  %k

			function obj = fill_fv(obj);
				fv = [];
				[fv.vertex,fv.face]=mne_read_surface(fullfile(obj.dirs.subj, 'surf', 'lh.orig'));
				obj.lh.orig.fv = fv;

				fv = [];
				[fv.vertex,fv.face]=mne_read_surface(fullfile(obj.dirs.subj, 'surf', 'rh.orig'));
				obj.rh.orig.fv = fv
			end %k
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
		end



		methods (Static)
			function V = concat_V_kern(rp)
				V = [];
				for i_kern = 1:length(rp.session.a_kern)
					ai_kern = rp.session.a_kern(i_kern);
					%              V = [V squeeze(rp.Vdata(rp.session.a_chan, ai_kern,:))];
					% V = [V squeeze(rp.Vdata(rp.session.a_chan, i_kern,:))];
					V = [V squeeze(rp.Vdata(:, i_kern,:))];
				end
			end
			function timefcn_handler(src, event)
				obj = event.AffectedObject;
				obj.update_timefcn_fig;
			end
		end
	end
