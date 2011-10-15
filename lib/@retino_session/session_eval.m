function obj = session_eval(obj, func_name)
	for i_patch = 1:length(obj.a_patch)
		ai_patch = obj.a_patch(i_patch);
		for i_source = 1:length(obj.a_source)
			ai_source = obj.a_source(i_source);
			t.rp = obj.retinoPatch(ai_source, ai_patch);
			eval(sprintf('t.rp.%s();', func_name));
		end
	end
end
