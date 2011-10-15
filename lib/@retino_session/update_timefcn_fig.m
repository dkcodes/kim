function update_timefcn_fig(obj)
	if isfield(obj.h,'timefcn')
		h1 = obj.h.ctf;
		data1 = obj.ctf;
		for i_data = size(data1,1)
			set(h1(i_data), 'YData', data1(i_data,:));
		end
		h2 = obj.h.ctf_emp;
		data2 = obj.ctf_emp;
		for i_data = size(data2,1)
			set(h2(i_data), 'YData', data2(i_data,:));
		end
	end
end
