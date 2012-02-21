cd('E:\raid\MRI\toolbox\kim')
clear

% Subject definitions
s_subj={
    'DK'   %1
%     'skeri0001'   %1
    };

g.dirs = 'tmp';

g.desc = sprintf('DK testing Femp\n');
g.list = s_subj;


% Stimulus Settings
n_spokes = 16; % needs > 4 (Left, right, up, down)
n_rings  = 6;

% Acquisition Settings
meg_chan           = 1:128;    % all MEG
eeg_chan           = 129:200;  % 1:55 EEG
ref_chan           = 75;
a_patch            = [1:96]; % Alternatively 'all', 'left', 'right', 'up', 'down'
a_source           = [1 2 3];
a_source_accounted = [1 2 3];
a_kern             = [1];
a_time             = 1:100;
a_chan             = [1:128];
a_days             = 1;

% fMRI Settings
% skeri00xy subjects 
% s_rois.name        = {'V3D-L'    'V2D-L'    'V1D-L'    'V1V-L'    'V2V-L'    'V3V-L' ...
%     'V3D-R'    'V2D-R'    'V1D-R'    'V1V-R'    'V2V-R'    'V3V-R'    };
% s_rois.type  = 'Gray';

s_rois.name        = {'V3D-L'    'V2D-L'  'V1-L'    'V2V-L'    'V3V-L' ...
    'V3D-R'    'V2D-R'   'V1-R'   'V2V-R'    'V3V-R'    };
s_rois.type  = 'Gray';
options.fmri.toggle     = true;
options.fmri.reset      = false;

% For simulation study
cfg_sim.ref_chan      = ref_chan;
cfg_sim.v_amplitude   = [1.5 1 1];
cfg_sim.src_time_type = 'thom';
% cfg_sim.src_time_type = 'linear_dependent';
cfg_sim.noise_level   = 0.0000;
cfg_sim.f_type        = '';
cfg_sim.external_amplitude = 0.0;

expt = set_field(   'n_spokes', 'n_rings', ...
                    'meg_chan', 'eeg_chan', 'ref_chan', ...
                    'a_patch', 'a_source', 'a_source_accounted', 'a_kern', ...
                    'a_time', 'a_chan', 'a_days',...
                    's_rois', ...
                    'cfg_sim', ...
                    'options' ...
                );

toggle_make_params = 1;
if toggle_make_params
    % Modify make_params.m to reflect experimental parameters.
    make_params(g, expt);
end

info = load_params(fullfile('in', 'param', g.dirs, 'info.mat'));
for i_subj = 1:numel(s_subj)
    this.filename = fullfile ('in', 'param', info.g.dirs, info.g.list{i_subj});
    p = load_params(this.filename); %#ok<*NASGU>
    run('sc_analyze_src');
    %   run('sc_svd');
end