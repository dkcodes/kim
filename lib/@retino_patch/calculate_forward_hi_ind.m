function obj = calculate_forward_hi_ind(obj)
	% also calculated individual Fx, Fy, Fz. Usually not called for speed.
	a_vert = obj.hiResVert;
	fwd = obj.session.fwd;
	rs = obj.session;
	a_chan = rs.a_chan;
	switch obj.hemi
		case 'L'
			src = fwd.src(1);
		case 'R'
			src = fwd.src(2);
		otherwise
			error();
	end
	nn = src.nn(a_vert,:); 
	aa = (rs.a(a_vert)-1)*3;
	Fx=fwd.sol.data(a_chan,1+aa);
	Fy=fwd.sol.data(a_chan,2+aa);
	Fz=fwd.sol.data(a_chan,3+aa);
	for i_vert = 1:length(a_vert)
		solInteobj(:, i_vert) = [Fx(:,i_vert) Fy(:,i_vert) Fz(:,i_vert)]*nn(i_vert,:)';
	end
	obj.F.individual.norm   = solInteobj;
	obj.F.individual.x      = Fx;
	obj.F.individual.y      = Fy;
	obj.F.individual.z      = Fz;

	obj.F.mean.norm  = mean(solInteobj,2);
	obj.F.mean.x     = mean(Fx,2);
	obj.F.mean.y     = mean(Fy,2);
	obj.F.mean.z     = mean(Fz,2);
end %k
