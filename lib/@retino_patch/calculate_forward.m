function obj = calculate_forward(obj)
	fwd = obj.session.fwd;
	switch obj.hemi
		case 'L'
			nn = fwd.src(1).nn(obj.loResVert,:);
		case 'R'
			nn = fwd.src(2).nn(obj.loResVert,:);
		otherwise
			error();
	end
	a_chan = 1:size(fwd.sol.data,1);
	F.a_chan = a_chan;
	for iPnt = size(obj.sourceInd,2):-1:1
		this.nn = nn(iPnt,:);
		Fx(:,iPnt) = fwd.sol.data(:,(1)+(obj.sourceInd(iPnt)-1)*3);
		Fy(:,iPnt) = fwd.sol.data(:,(2)+(obj.sourceInd(iPnt)-1)*3);
		Fz(:,iPnt) = fwd.sol.data(:,(3)+(obj.sourceInd(iPnt)-1)*3);
		solInteobj(:,iPnt) = [Fx(:,iPnt) Fy(:,iPnt) Fz(:,iPnt)]*this.nn';
	end
	F.individual.norm   = solInteobj;
	F.individual.x      = Fx;
	F.individual.y      = Fy;
	F.individual.z      = Fz;

	F.mean.norm  = mean(solInteobj,2);
	F.mean.x     = mean(Fx,2);
	F.mean.y     = mean(Fy,2);
	F.mean.z     = mean(Fz,2);
	obj.F = F;
end %k
