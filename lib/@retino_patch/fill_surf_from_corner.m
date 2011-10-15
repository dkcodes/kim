function obj = fill_surf_from_corner(obj)
	switch obj.hemi
		case 'L'
			all_vert = obj.session.lh.flat.vert_full;
			fv =  obj.session.lh.orig.fv;
		case 'R'
			all_vert = obj.session.rh.flat.vert_full;%   
			fv =  obj.session.rh.orig.fv;
		otherwise
			error('Unknown hemisphere');
	end
	%          [junk, ia, ib] = intersect(all_vert(:,1), obj.hiResCornerVert);
	a = all_vert(obj.flat.hi_res_vert,:);
	%          b(ib,:) = all_vert(ia,:);
	b = all_vert(obj.hiResCornerVert,:);
	L = insidepoly(a(:,2),a(:,3),b(:,2),b(:,3), 'tol', 0);
	obj.hiResVert = a(L,1);

	a=(ismember(fv.face, obj.hiResVert));
	[a,b] = find(a);
	obj.fv.faces = fv.face(a,:);
	obj.fv.vertices = fv.vertex;
end %k
