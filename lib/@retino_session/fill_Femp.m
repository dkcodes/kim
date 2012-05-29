function obj = fill_Femp(obj, chanType,  a_patch)
    if nargin<3
        a_patch = obj.a_patch;
    end
	for i_patch = 1:length(a_patch)
		ai_patch = a_patch(i_patch);
		t.rp = obj.retinoPatch(1, ai_patch); % V's are all the same regardless of ai_source
		rowInd = select_chan(obj, chanType, i_patch);
		V(rowInd,:) = obj.concat_V_kern(t.rp);
	end
	Femp = V/obj.ctf;
	for i_patch = 1:length(a_patch)
		ai_patch = a_patch(i_patch);
		for i_source = 1:length(obj.a_source)
			ai_source = obj.a_source(i_source);
			t.rp = obj.retinoPatch(ai_source, ai_patch);
			rowInd = select_chan(obj, chanType, i_patch);
			t.rp.Femp.mean.norm(obj.a_chan,:) = Femp(rowInd,i_source);
		end
	end
end
