function obj = fill_patch_source_index(obj)
	rp = obj.retinoPatch;
	for i = 1:length(rp)
		a(rp(i).ind, rp(i).area) = i;
	end
	obj.patch_source_index = a;
end
