function obj = fill_pt(obj)
	i_rp = 0;
	for i_patch = 1:length(obj.a_patch)
		ai_patch = obj.a_patch(i_patch);
		for i_source = 1:length(obj.a_source)
			ai_source = obj.a_source(i_source);
			i_rp = i_rp + 1;
			t.rp = obj.retinoPatch(ai_source, ai_patch);
			hemi(1:4, i_rp) = t.rp.hemi;
			cv(:,i_rp) = t.rp.hiResCornerVert;
		end
	end
	hemi = hemi(:);
	cv = cv(:);
	[asdf_vert, tab] = unique(cv);
	asdf_hemi = hemi(tab);
	for i = 1:length(asdf_vert)
		pt(i).vert = asdf_vert(i);
		pt(i).hemi = asdf_hemi(i);
		pt(i).patch = [];
	end
	for i_pt = 1:length(pt)
		i_rp = 0;
		for i_patch = 1:length(obj.a_patch)
			ai_patch = obj.a_patch(i_patch);
			for i_source = 1:length(obj.a_source)
				ai_source = obj.a_source(i_source);
				i_rp = i_rp + 1;
				t.rp = obj.retinoPatch(ai_source, ai_patch);


				[asdf, tab] = ismember(pt(i_pt).vert, t.rp.hiResCornerVert);
				if ~isempty(find(tab))
					i_patch = length(pt(i_pt).patch)+1;
					pt(i_pt).patch(i_patch) = i_rp;
					pt(i_pt).area(i_patch) = ai_source;
					pt(i_pt).ind(i_patch)  = ai_patch;
					pt(i_pt).corner_ind(i_patch) = tab;
				end
			end
		end
	end
	obj.pt = pt;
end
