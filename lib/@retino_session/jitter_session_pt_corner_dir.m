function obj = jitter_session_pt_corner_dir(obj,vect)
	pt = obj.pt;
	for i_pt = 1:length(pt)
		pt_i = pt(i_pt);
		hemi = pt_i.hemi;
		switch hemi
			case 'L'
				vert_full = obj.lh.flat.vert_full;
			case 'R'
				vert_full = obj.rh.flat.vert_full;
			otherwise
				error('');
		end
		for i_patch = 1
			ai_patch  = pt_i.ind(1);
			ai_source = pt_i.area(1);
			ai_corner = pt_i.corner_ind(1);

			t.rp = obj.retinoPatch(ai_source, ai_patch);
			t.hiResCornerVert = t.rp.hiResCornerVert(ai_corner);

			t.vert = vert_full(t.hiResCornerVert,2:4);
			next.vert = t.vert + vect;
			[a,b]=nearpoints(vert_full(:,2:4)', next.vert');
			b(b==0) = inf;
			[a, b]=min(b);
			next.hiResCornerVert = b;
		end
		for i_patch = 1:length(pt_i.ind)
			ai_source = pt_i.area(i_patch);
			ai_patch = pt_i.ind(i_patch); % Does not matter which patch I choose
			ai_corner = pt_i.corner_ind(i_patch);

			t.rp = obj.retinoPatch(ai_source, ai_patch);
			t.rp.hiResCornerVert(ai_corner) = next.hiResCornerVert;
		end
	end
end
