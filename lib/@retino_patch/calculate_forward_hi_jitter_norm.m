function obj = calculate_forward_hi_jitter_norm(obj)
	a_vert = obj.hiResVert;
	rs = obj.session;
	a_chan = rs.a_chan;
	fwd = obj.session.fwd;
	jitter_angle = pi/12;

	Rx = @(x) [1 0 0; 0 cos(x) -sin(x); 0 sin(x) cos(x)];
	Ry = @(x) [cos(x) 0 sin(x); 0 1 0; -sin(x) 0 cos(x)];
	Rz = @(x) [cos(x) -sin(x) 0; sin(x) cos(x) 0; 0 0 1];
	alpha = 0; 
	switch obj.hemi
		case 'L'
			src = fwd.src(1);
			nn=zeros(numel(a_vert),3);
			for i_vert = 1:numel(a_vert)
				ai_vert = a_vert(i_vert);
				gamma = rand*jitter_angle; beta = rand*jitter_angle; R = Rx(gamma)*Ry(beta)*Rz(alpha);
				nn(i_vert,:) = src.nn(ai_vert,:)*R*src.source_weight(ai_vert,:);
			end
			aa = (rs.a(a_vert)-1)*3;
		case 'R'
			src = fwd.src(2);
			nn=zeros(numel(a_vert),3);
			for i_vert = 1:numel(a_vert)
				ai_vert = a_vert(i_vert);
				gamma = rand*jitter_angle; beta = rand*jitter_angle; R = Rx(gamma)*Ry(beta)*Rz(alpha);
				nn(i_vert,:) = src.nn(ai_vert,:)*R*src.source_weight(ai_vert,:);
			end
			aa = (fwd.src(1).nuse + int32(rs.b(a_vert)-1))*3;
		otherwise
			error();
	end
	Fx=fwd.sol.data(a_chan,1+aa);
	Fy=fwd.sol.data(a_chan,2+aa);
	Fz=fwd.sol.data(a_chan,3+aa);

        % temporary: referencing to electrode 75
        Fx = Fx - repmat(Fx(75,:), size(Fx, 1), 1 );
        Fy = Fy - repmat(Fy(75,:), size(Fy, 1), 1 );
        Fz = Fz - repmat(Fz(75,:), size(Fz, 1), 1 );



	obj.F.bem_jittered_norm.mean.norm(a_chan,:)  = [Fx Fy Fz]*nn(:);
	%obj.F.bem_jittered_norm.mean.norm  = [Fx Fy Fz]*nn(:);
end %k
