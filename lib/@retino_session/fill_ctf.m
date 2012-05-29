function obj = fill_ctf(obj, chanType, a_patch)
	V = []; F = [];
    if nargin<3
        a_patch = obj.a_patch;
    end
	for i_patch = 1:length(a_patch)
		ai_patch = a_patch(i_patch);
		rowInd = select_chan(obj, chanType, i_patch);
		for i_source = 1:length(obj.a_source)
			ai_source = obj.a_source(i_source);
			t.rp = obj.retinoPatch(ai_source, ai_patch);
			F(rowInd, i_source) = t.rp.F.mean.norm(obj.a_chan, :);
        end
        t.V = obj.concat_V_kern(t.rp); % Data is same for all i_source
        V(rowInd,:) = t.V;
	end
	obj.ctf = F\V;
end
