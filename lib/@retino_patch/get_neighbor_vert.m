function out = get_neighbor_vert(obj, corner_vert_ind)
	switch obj.hemi
		case 'L'
			src = obj.session.fwd.src(1);
		case 'R'
			src = obj.session.fwd.src(2);
		otherwise
			error('Invalid hemisphere')
	end
	[a,b]=find(src.tris == obj.hiResCornerVert(corner_vert_ind));
	out = unique(src.tris(a,:));
	%           out = setdiff(out, obj.hiResCornerVert(corner_vert_ind));
	%           rr = src.rr;
	%           x = rr(a,1);y = rr(a,2);z = rr(a,3); tri = src.tris(a,:);
	%           plot3(rr(1:100:end,1), rr(1:100:end,2), rr(1:100:end,3), '.')
	%           hold on;
	%           trimesh(tri,rr(:,1),rr(:,2),rr(:,3),rr(:,3),'LineWidth', 5); axis vis3d equal
end %k
