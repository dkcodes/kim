function out = select_data_ind(obj, a_patch, chanType)
	aEP_data = []; nAllChan = length([obj.megChan obj.eegChan]);
	switch chanType
		case 'meg'
			chan = obj.megChan;
		case 'eeg'
			chan = obj.eegChan;
		case 'meeg'
			chan = [obj.megChan obj.eegChan];
		otherwise
			error('Must define channel type');
	end
	for i_patch = 1:length(a_patch)
		aEP_data = [aEP_data (chan)+(find(obj.a_patch==a_patch(i_patch))-1)*nAllChan];
	end
	out = aEP_data;
end
