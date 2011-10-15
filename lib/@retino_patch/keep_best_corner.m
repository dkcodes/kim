function obj = keep_best_corner(obj, next_SSE, corner_vert_ind)
	if isfield(obj.keep, 'prev_corner')
		curr_hiResCornerVert = obj.hiResCornerVert(corner_vert_ind);
		obj.keep.prev_corner{corner_vert_ind}(curr_hiResCornerVert) = 1;
		obj.keep.prev_SSE{corner_vert_ind}(curr_hiResCornerVert) = next_SSE;
	else
		obj.keep.prev_corner{corner_vert_ind} = [];
		obj.keep.prev_SSE{corner_vert_ind} = [];
	end
	if isfield(obj.keep, 'best_SSE')
		if next_SSE < obj.keep.best_SSE
			obj.keep.best_SSE =  next_SSE;
			obj.keep.best_corner_vert = obj.hiResCornerVert;
		end
	else
		obj.keep.best_SSE = 10;
		obj.keep.best_corner_vert = obj.hiResCornerVert;
	end
end %k
