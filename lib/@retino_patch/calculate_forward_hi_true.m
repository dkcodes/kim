function obj = calculate_forward_hi_true(obj, fwd)
	a_vert = obj.hiResVert;
	rs = obj.session;
	a_chan = rs.a_chan;
	switch obj.hemi
		case 'L'
			src = fwd.src(1);
			nn = src.nn(a_vert,:).*repmat(src.source_weight(a_vert,:),[1 3]);
			aa = (rs.a(a_vert)-1)*3;
		case 'R'
			src = fwd.src(2);
			nn = src.nn(a_vert,:).*repmat(src.source_weight(a_vert,:),[1 3]);
			aa = (fwd.src(1).nuse + int32(rs.b(a_vert)-1))*3;
		otherwise
			error();
	end
	Fx=fwd.sol.data(a_chan,1+aa);
	Fy=fwd.sol.data(a_chan,2+aa);
	Fz=fwd.sol.data(a_chan,3+aa);
	obj.F.true.mean.norm  = [Fx Fy Fz]*nn(:);
end %k
