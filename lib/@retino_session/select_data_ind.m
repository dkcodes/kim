function out = select_data_ind(obj, a_patch, chanType)
	aEP_data = []; nAllChan = length([obj.meg_chan obj.eeg_chan]);
	switch chanType
		case 'meg'
			a_chan = obj.meg_chan;
		case 'eeg'
			a_chan = obj.eeg_chan;
		case 'meeg'
			a_chan = [obj.meg_chan obj.eeg_chan];
		otherwise
			error('Must define channel type');
	end
	for i_patch = 1:length(a_patch)
		aEP_data = [aEP_data (a_chan)+(find(obj.a_patch==a_patch(i_patch))-1)*nAllChan];
	end
	out = aEP_data;
end
