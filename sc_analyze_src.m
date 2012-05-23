close all;
% clearvars -regexp .* -except subj_id i_sub s_subj t_svd n_spokes n_rings n_patch a_source_accounted noise_level f roi_area dot_prod_1 stat
try, rmappdata(0, 'fwd'); end
addpath('./lib'); add_lib();
sc_load_fieldnames();

dirs.data        = getenv('ANATOMY_DIR');
dirs.data        = 'E:\raid\MRI\anatomy';
dirs.fs4_data    = fullfile(dirs.data, 'FREESURFER_SUBS');
dirs.subj        = fullfile(dirs.fs4_data, [subj_id '_fs4']);
dirs.eeg         = fullfile(dirs.subj, [subj_id '_EEG']);
dirs.bem         = fullfile(dirs.eeg, 'bem');
dirs.mne         = fullfile(dirs.eeg, '_MNE_');
dirs.berkeley    = fullfile(dirs.data, 'Berkeley', subj_id);
fwd_filename     = fullfile(dirs.mne, [subj_id '-fwd.fif']);
sph_fwd_filename = fullfile(dirs.mne, [subj_id '-sph-fwd.fif']);

%% Environment preparations
if isempty(getappdata(0, 'fwd'))
  % To speed up loading very large data matrices
  disp('saving root variables');
  if ~exist('fwd', 'var')
    fwd=mne_read_forward_solution(fwd_filename);
    sph_fwd = mne_read_forward_solution(sph_fwd_filename);
  end
  fwdtrue = fwd;
  setappdata(0, 'fwd',        fwd);
  setappdata(0, 'fwdtrue',    fwdtrue);
else
  close all; clc;
  fwd     = getappdata(0, 'fwd');
  fwdtrue = getappdata(0, 'fwdtrue');
end %k

%fwd = sph_fwd;
n_time   = numel(a_time);
n_chan   = length(a_chan);
n_source = length(a_source);
n_kern   = numel(a_kern);
VEPavg   = NaN(n_patch, n_chan, n_time);

%% Define Session
rs = retino_session;

rs.dirs = dirs;
rs.subj_id = subj_id;
rs.rois = s_rois;

rs.design.n_spokes = n_spokes;
rs.design.n_rings  = n_rings;

rs.a_patch      = a_patch;
rs.data.mean    = VEPavg;
rs.a_chan       = a_chan;
rs.a_time       = a_time;
rs.fwd          = fwd;
rs.sph_fwd      = sph_fwd;
rs.a_source     = a_source;
rs.a_kern       = a_kern;
rs.meg_chan     = meg_chan;
rs.eeg_chan     = eeg_chan;
rs.options      = options;
rs.h.main.fig   = h_main;
clear -regexp fwd

rs.interpolate_fwd();
r_pre                = retino_preproc(rs);
% cfg_corner_vert.type = 'patch';
% rs.fill_default_corner_vert(cfg_corner_vert);
rs.fill_fv();

%% Initialize patches
tic;
rs.init_session_patch();
rp = rs.retinoPatch;
rs.fill_rois_area();
%% Make Interactive Figure
figure(rs.h.main.fig); close(rs.h.main.fig);
clear rplot;
rplot       = retino_plotter;
cfg.rs      = rs;
cfg.a_patch = [];%rs.a_patch;
rplot.cfg   = cfg;
rplot.plot_flat;

%% Define Simulation parameters
% rs.a_kern             = [1 2 3 4 5];
toggle_simdata          = 1;
if isequal(toggle_simdata, 1)
  cfg_sim      = p.cfg_sim;
  cfg_sim.rs   = rs;                    %  Define simulation configuration
  r_sim        = retino_sim(cfg_sim);   % Construct simulation object
  VEPavg_sim   = r_sim.make_sim_data(); % Do Simulation
  rs.data.mean = VEPavg_sim;            % fill rs.data.mean with simulated data
  V            = rs.sim.true.timefcn;   % fill V with true V
  clear VEP*
end
rs.a_source = a_source_accounted;
rs.fill_session_patch_Vdata;

rs.fill_ctf(rs.a_patch, 'meg');
rs.fill_session_patch_timefcn;
rs.fill_Femp(rs.a_patch, 'meg');
% rs.fill_ctf_Femp(rs.a_patch, 'meg');
rs.fill_session_patch_timefcn_emp;
continue;
disp('11111111111111111111111111111111111111111111111');
rs.sim.i_sub = i_sub;
rplot.plot_flat_rois();
stat(i_sub, :) = rs.sim.patch_stat;
return
