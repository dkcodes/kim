function obj = fill_source_weight(obj)
	for i_hemi = 1:2
		src=obj.fwd.src(i_hemi);
		tris = src.tris;
		rr = src.rr;
		tic
		hemi_weight = zeros(size(rr,1),1);
		for i_tris = 1:length(tris)
			i_vert = tris(i_tris,:);
			a_rr = rr(tris(i_tris,:),:);
			v1=a_rr(1,:)-a_rr(2,:);
			v2=a_rr(1,:)-a_rr(3,:);
			%                     v3=a_rr(2,:)-a_rr(3,:);
			hemi_weight(i_vert)=norm(cross(v1,v2)/2/3)+hemi_weight(i_vert);
			if mod(i_tris,10000) == 0, disp(sprintf('%g of %g', i_tris, length(tris))); end
		end
		obj.fwd.src(i_hemi).source_weight = hemi_weight;
	end
end
