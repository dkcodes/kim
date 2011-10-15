function out = calculate_common_time_fcn(obj, a_patch, chanType)
	avgdata = obj.data.mean;
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
	nSource = 2; %% This should be taken out to script/session settings for generality
	nAllChan = length([obj.megChan obj.eegChan]);
	for i_patch = 1:length(a_patch)
		aEP_F = (1:nAllChan)+(i_patch-1)*nAllChan;
		for i_source = 1:nSource
			ai_patch = obj.find_patch_source_index(a_patch(i_patch), i_source);

			t.sign = 1;
			if (i_source == 2) && ~isempty(find([2 6 7 9 10 14 15 28 29 21 22 23 27 29 30 31] == a_patch(i_patch)))
				%                   if (i_source == 2) && ~isempty(find([2 3 4 13 17 20 25 26 28 32] == a_patch(i_patch)))
				t.sign = -1;
			end

			F.meeg(aEP_F,i_source) = t.sign*obj.retinoPatch(ai_patch).F.mean.norm(1:nAllChan);
		end
	end
	% Rescale M/EEG signals and forward matrix
	% Here I found that ME_Factor of 1e7 to be good
	aEP_data = []; aEP_F = []; aEP_F_meg = []; aEP_data_meg = [];
	for i_patch = 1:length(a_patch)
		aEP_data = [aEP_data (chan)+(find(obj.a_patch==a_patch(i_patch))-1)*nAllChan];
		%             aEP_eeg_data = [aEP_eeg_data (obj.eegChan)+(find(obj.a_patch==a_patch(i_patch))-1)*nAllChan];
		aEP_data_meg = [aEP_data_meg (obj.megChan)+(find(obj.a_patch==a_patch(i_patch))-1)*nAllChan];
		aEP_F = [aEP_F (chan)+(i_patch-1)*nAllChan];
		aEP_F_meg = [aEP_F_meg obj.megChan+(i_patch-1)*nAllChan];
	end
	ME_Factor = [1*1e-7];
	avgdata(aEP_data_meg,:) = avgdata(aEP_data_meg,:)/ME_Factor;
	t.avgdata_rescaled   = avgdata(aEP_data,:);
	F.meeg(aEP_F_meg,:)  = F.meeg(aEP_F_meg,:)/ME_Factor;
	t.F.meeg_rescaled = F.meeg(aEP_F,:);
	Tprime_MEEG = (t.F.meeg_rescaled'*t.F.meeg_rescaled)\t.F.meeg_rescaled'*t.avgdata_rescaled; % for 1 source only, 1st iternation
	out=Tprime_MEEG;
end
