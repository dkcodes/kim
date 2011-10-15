function obj = fill_patch_time_fcn(obj)
	rs = obj.session;
	obj.timefcn = obj.F.mean.norm(rs.a_chan,:)\obj.Vdata;
end %k
