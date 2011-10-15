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
