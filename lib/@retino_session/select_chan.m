function out = select_chan(obj, chanType, iRetinoPatch)
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
	if nargin < 3
		iRetinoPatch = 1;
	end
	nChan = size(a_chan,2);
	out = (1:nChan)+(iRetinoPatch-1)*nChan;
end
