function out = calculate_svd(obj, a_patch, chanType)
	avgdata = obj.data.mean;
	data_ind = obj.select_data_ind(a_patch, chanType);
	[obj.ctf.svd.u, obj.ctf.svd.s, obj.ctf.svd.t]=svd(avgdata(data_ind,:));
	obj.ctf.svd.a_patch = a_patch;
	out = 1;
end
