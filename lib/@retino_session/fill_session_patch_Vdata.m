function obj = fill_session_patch_Vdata(obj, a_kern)
	if ~exist('a_kern', 'var')
		a_kern = obj.a_kern;
	end
	for i_patch = 1:length(obj.a_patch)
		ai_patch = obj.a_patch(i_patch);
		for i_source = 1:length(obj.a_source)
			ai_source = obj.a_source(i_source);
			t.rp = obj.retinoPatch(ai_source, ai_patch);
			%t.rp.fill_Vdata(obj.data.mean(:,:,a_kern,:));
            t.rp.fill_Vdata(obj.data.current(:,:,a_kern,:));
		end
	end
end
