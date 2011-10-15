function obj = fill_surf_from_corner2(obj)
	switch obj.hemi
		case 'L'
			rcorner = obj.session.lh.nodesAll(obj.hiResCornerVert,2:4);
			rbox = obj.session.lh.nodes;
		case 'R'
			rcorner = obj.session.rh.nodesAll(obj.hiResCornerVert,2:4);
			rbox = obj.session.rh.nodes;
		otherwise
			error();
	end
	xmin = min(rcorner(:,1))-abs(min(rcorner(:,1))*.1);
	xmax = max(rcorner(:,1))+abs(max(rcorner(:,1))*.1);
	ymin = min(rcorner(:,2))-abs(min(rcorner(:,2))*.1);
	ymax = max(rcorner(:,2))+abs(max(rcorner(:,2))*.1);
	zmin = min(rcorner(:,3))-abs(min(rcorner(:,3))*.1);
	zmax = max(rcorner(:,3))+abs(max(rcorner(:,3))*.1);

	%          rbox_w = rbox;
	rbox_w = rbox(  (rbox(:,2)<=xmax & rbox(:,2) >= xmin) & ...
		(rbox(:,3)<=ymax & rbox(:,3) >= ymin) & ...
		(rbox(:,4)<=zmax & rbox(:,4) >= zmin),:);

	v1 = rcorner(1,:)-rcorner(2,:);
	v2 = rcorner(2,:)-rcorner(3,:);
	%

	uvec = [v1' v2'];
	uvc = rcorner*uvec;
	uv = rbox_w(:,2:4)*uvec;
	a = uv(:,1);
	b = uv(:,2);
	c = uvc(:,1);
	d = uvc(:,2);
	L = insidepoly(a,b,c,d, 'tol', 0);
	%          L = inpoly(uv', uvc');
	obj.hiResVert = rbox_w(L,1);
end %k
