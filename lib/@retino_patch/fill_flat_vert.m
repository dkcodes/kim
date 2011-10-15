function obj = fill_flat_vert(obj)
	switch obj.hemi
		case 'L'
			all_vert = obj.session.lh.flat.vert_full;
		case 'R'
			all_vert = obj.session.rh.flat.vert_full;%                
		otherwise
			error('Unknown hemisphere');
	end
	[junk, ind] = intersect(all_vert(:,1), obj.hiResCornerVert);
	this.pt = all_vert(ind,:);
	[a1, a2]=nearpoints(all_vert(:,2:4)', this.pt(:,2:4)');
	obj.flat.hi_res_vert = find(a2<120);
end %k
