function obj = fill_sources_from_surf(obj, fwd)
	switch obj.hemi
		case 'L'
			%                [obj.loResVert, obj.sourceInd]=intersect(obj.session.fwd.src(1).vertno, obj.hiResVert);
			obj.loResVert = intersect_sorted(fwd.src(1).vertno, int32(obj.hiResVert));
		case 'R'
			%                [obj.loResVert, obj.sourceInd]=intersect(obj.session.fwd.src(2).vertno, obj.hiResVert);
			obj.loResVert = intersect_sorted(fwd.src(2).vertno, int32(obj.hiResVert));
		otherwise
			error();
	end
end %k
