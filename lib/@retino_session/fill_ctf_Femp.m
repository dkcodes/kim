function obj = fill_ctf_Femp(obj, a_patch, chanType)
	V = []; F = [];
	for i_patch = 1:length(obj.a_patch)
		ai_patch = obj.a_patch(i_patch);
		rowInd = select_chan(obj, chanType, i_patch);
		for i_source = 1:length(obj.a_source)
			ai_source = obj.a_source(i_source);
			t.rp = obj.retinoPatch(ai_source, ai_patch);

			V(rowInd,:) = obj.concat_V_kern(t.rp);
			F(rowInd, i_source) = t.rp.Femp.mean.norm(obj.chan, :);
		end
	end
	obj.ctf_emp = F\V;
end
