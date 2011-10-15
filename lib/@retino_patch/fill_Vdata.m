function obj = fill_Vdata(obj, Vdata)
	%             obj.Vdata = squeeze(Vdata(obj.ind,:,:,:));
	rs = obj.session;
	n_chan = numel(rs.chan);
	n_kern = numel(rs.a_kern);
	n_time = numel(rs.time);
	%obj.Vdata = reshape(Vdata(obj.ind,:,1:n_kern,:), n_chan, n_kern, n_time) ;
	obj.Vdata = reshape(Vdata(obj.ind, rs.chan,1:n_kern,:), n_chan, n_kern, n_time) ;
end %k
