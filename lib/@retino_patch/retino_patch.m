classdef retino_patch < handle
   properties (SetObservable = true)
      session
      
      name
      ind
      hemi
      area
      roi
      
      loResVert
      hiResVert
      loResEdgeVert
      hiResEdgeVert
      loResCornerVert
      hiResCornerVert
      hiResFlatVert
      hi_res_norm
      
      timefcn
      timefcn_emp
      
      sourceInd
      F
      Femp
      Vdata
      
      normalvec
      uvHiResVert
      
      h
      faceColor
      edgeColor
      
      sim
      keep
      
      flat
      fv
   end %k
   methods
		 function make_stl(obj)
			 rs=obj.session;
			 system(sprintf('mkdir -p %s', fullfile(rs.dirs.berkeley, 'stl')));
			 stl_name = fullfile(rs.dirs.berkeley, 'stl', sprintf('%02g_%02g', obj.area, obj.ind));
			 disp(stl_name);
			 this.fv.vertices = obj.fv.vertices*1000;
			 this.fv.faces = obj.fv.faces;
			 patch2stl(stl_name, this.fv);
		 end %k
	 end
	 methods (Static)
		 function hi_res_corner_vert_handler(src, event)
			 %          obj = event.AffectedObject;
			 %          obj.fill_surf_from_corner();
			 %          obj.fill_sources_from_surf(obj.session.fwd);
			 %          obj.calculate_forward_hi(obj.session.fwd);
			 %          if ~isempty(obj.h)
			 update_fig(obj, 'corner')
			 update_fig(obj, 'surf')
		 end %k
	 end
 end
