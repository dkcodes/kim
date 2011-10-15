function obj = fill_session_patch_flat_vert(obj)
	for iSessPatch = 1:size(obj.retinoPatch,2)
		obj.retinoPatch(iSessPatch).fill_flat_vert();
	end
end
