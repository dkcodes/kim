function add_lib()
	if ~isequal(getappdata(0, 'pathed'), 1)
		% Add Paths
		addpath(genpath('./lib'));
		osType = computer;
		if isequal(osType, 'GLNX86') || isequal(osType, 'GLNXA64')
			addpath('/raid/MRI/toolbox/vistasoft/trunk/mrAnatomy/');
			addpath('/raid/MRI/toolbox/vistasoft/trunk/mrLoadRet/Utilities/');
			addpath('/raid/MRI/toolbox/vistasoft/trunk/mrAnatomy/VolumeUtilities');
		else
			addpath('D:\raid\MRI\toolbox\mne\share\matlab');
			addpath('D:\raid\MRI\toolbox\vistasoft\trunk\mrAnatomy')
			addpath('D:\raid\MRI\toolbox\vistasoft\trunk\mrAnatomy\VolumeUtilities')
			addpath('D:\raid\MRI\toolbox\vistasoft\trunk\mrData')
		end
		setappdata(0, 'pathed', 1);
	end

