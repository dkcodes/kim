function update_timefcn_fig(obj)
	if isfield(obj.h,'timefcn')
		h = obj.h.timefcn.source;
		data = obj.timefcn.source;
		set(h, 'YData', data);
	end
end %k
