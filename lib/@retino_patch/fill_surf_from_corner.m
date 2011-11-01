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
  
  fwd = obj.session.fwd;
  a_vert = obj.hiResVert;
  switch obj.hemi
  case 'L'
      src = fwd.src(1);
      nn = src.nn(a_vert,:).*repmat(src.source_weight(a_vert,:),[1 3]);
      rr = src.rr(a_vert,:);
    case 'R'
      src = fwd.src(2);
      nn = src.nn(a_vert,:).*repmat(src.source_weight(a_vert,:),[1 3]);
      rr = src.rr(a_vert,:);
    otherwise
      error();
  end
  obj.hi_res_norm.data = nn;
  obj.hi_res_norm.sum = sum(nn);
  obj.hi_res_norm.pos = rr;
  obj.reject_bad_vert();



	
  a=(ismember(fv.face, obj.hiResVert));
	[a,b] = find(a);
	obj.fv.faces = fv.face(a,:);
	obj.fv.vertices = fv.vertex;
end %k
