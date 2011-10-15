function obj = set_corner_vert(obj, corner_vert_ind)
	sim.prev_hiResCornerVert = obj.hiResCornerVert;
	setappdata(0, 'sim', sim);
	possible_vert = obj.get_neighbor_vert(corner_vert_ind);
	n_vert = size(possible_vert,1);
	rand_vert_ind = randperm(n_vert);
	obj.hiResCornerVert(corner_vert_ind) = possible_vert(rand_vert_ind(1));
end %k
