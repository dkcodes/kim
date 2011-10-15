function out = select_chan(obj, chanType, iRetinoPatch)
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
	if nargin < 3
		iRetinoPatch = 1;
	end
	nChan = size(chan,2);
	out = (1:nChan)+(iRetinoPatch-1)*nChan;
end
