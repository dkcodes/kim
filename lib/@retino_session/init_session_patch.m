function init_session_patch(obj)
	n_source = numel(obj.a_source);
	c1 = jet(32*n_source); c{1} = c1(1:32,:); %c = c(randperm(16),:);
	c2 = jet(32*n_source); c{2} = c2(33:end,:);
	c3 = jet(32*n_source); c{3} = c3(65:end,:);
	for i_source = 1:length(obj.a_source)
		ai_source = obj.a_source(i_source);
		fprintf('Building >> Source %g ::: Patch ', i_source);
		for i_patch = 1:length(obj.a_patch)
			ai_patch = obj.a_patch(i_patch);

			rp(ai_source, ai_patch) = retino_patch;
			rp(ai_source, ai_patch).session = obj;
			t.rp = rp(ai_source, ai_patch);
			% Finds in the design matrix the roi file list corresponding to (iPatch, iSource)
			t.rp.ind      = ai_patch;
			t.rp.area     = ai_source;
			t.rp.hiResCornerVert             = obj.default_corner_vert.patch(ai_source, ai_patch).hiResCornerVert;
			t.rp.hemi                        = obj.default_corner_vert.patch(ai_source, ai_patch).hemi;
			try
				t.rp.faceColor = c{i_source}(ai_patch,:);
				t.rp.edgeColor = c{i_source}(ai_patch,:);
			catch
				t.rp.faceColor = [rand rand rand];
				t.rp.edgeColor = [rand rand rand];
			end
			t.rp.fill_flat_vert();
			t.rp.fill_surf_from_corner();
			t.rp.calculate_forward_hi();
			t.rp.calculate_forward_hi_jitter_norm();
			%       t.rp.calculate_forward_hi_true(fwdtrue);
			fprintf('%02g ', i_patch);
		end
		fprintf(' ::: %0.1g sec \n', toc);
	end
	obj.retinoPatch = rp;
	obj.fill_pt();
end
