function obj = interpolate_fwd(obj)
	l_rr = obj.fwd.source_rr(1:length(obj.fwd.src(1).vertno),:);
	r_rr = obj.fwd.source_rr((obj.fwd.src(1).nuse+1):end,:);
	obj.a=nearpoints(obj.fwd.src(1).rr',l_rr');
	obj.b=nearpoints(obj.fwd.src(2).rr',r_rr');
end
