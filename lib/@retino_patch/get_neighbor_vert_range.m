function out = get_neighbor_vert_range(obj, corner_vert_ind, range)
	switch obj.hemi
		case 'L'
			vert_full = obj.session.lh.flat.vert_full;
		case 'R'
			vert_full = obj.session.rh.flat.vert_full;
		otherwise
			error('Invalid hemisphere')
	end
	[a, b] = nearpoints(vert_full(:,2:4)',...
		vert_full(obj.hiResCornerVert(corner_vert_ind),2:4)');
	out = find(b<range & b ~=0);
end %k
