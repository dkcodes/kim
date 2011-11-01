close all;

% clearvars -regexp .* -except subj_id i_sub s_subj t_svd n_spokes n_rings n_patch a_source_accounted noise_level f roi_area dot_prod_1 stat

try, rmappdata(0, 'fwd'); end
addpath('./lib');
add_lib();
sc_load_fieldnames();

dirs.data        = getenv('ANATOMY_DIR');
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

rs.a_patch   = a_patch;
rs.data.mean = VEPavg;
rs.a_chan    = a_chan;
rs.a_time    = a_time;
rs.fwd       = fwd;
rs.sph_fwd   = sph_fwd;
rs.a_source  = a_source;
rs.a_kern    = a_kern;
rs.meg_chan  = meg_chan;
rs.eeg_chan  = eeg_chan;
clear -regexp fwd

rs.interpolate_fwd();
r_pre                = retino_preproc(rs);
cfg_corner_vert.type = 'patch';
rs.fill_default_corner_vert(cfg_corner_vert);
rs.fill_fv();

%% Initialize patches
tic;
rs.init_session_patch();
rp = rs.retinoPatch;

%% Make Interactive Figure
figure(171); close(171);
clear rplot;
rplot       = retino_plotter;
cfg.rs      = rs;
cfg.a_patch = [];%rs.a_patch;
rplot.cfg   = cfg;
rplot.plot_flat;

%% Define Simulation parameters
% rs.a_kern           = [1 2 3 4 5];
toggle_simdata        = 1;
if toggle_simdata     == 1
  cfg_sim.rs          = rs;                    %  Define simulation configuration
  cfg_sim.noise_level = noise_level;
  cfg_sim.ref_chan    = p.ref_chan;
  cfg_sim.v_amplitude = p.v_amplitude;
  r_sim               = retino_sim(cfg_sim);   % Construct simulation object
  VEPavg_sim          = r_sim.make_sim_data(); % Do Simulation
  rs.data.mean        = VEPavg_sim;            % fill rs.data.mean with simulated data
  V                   = rs.sim.true.timefcn;   % fill V with true V
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


%c_pair = {[1 1], [2 2], [3 3], [1 2], [1 3], [2 3]};
%all_F = [];
%for ai_patch = a_patch
%all_F = [all_F [rp(1, ai_patch).F.mean.norm'; rp(2, ai_patch).F.mean.norm'; rp(3, ai_patch).F.mean.norm']]; 
%end
%for i_pair = 1:numel(c_pair)
%ci_pair = c_pair{i_pair};
%dot_prod_1(i_sub, i_pair) = sum(all_F(ci_pair(1),:) .* all_F(ci_pair(2),:));
%end


return

for ai_patch = a_patch
  %roi_area(i_sub, ai_source) = 0;
  dot_prod_2(ai_patch, 1) = 0;
  for i_pair = 1:numel(c_pair)
    ci_pair = c_pair{i_pair};
    dot_prod_2(ai_patch, i_pair) = ...
      sum(rp(ci_pair(1), ai_patch).F.mean.norm .* rp(ci_pair(2), ai_patch).F.mean.norm);
    %roi_area(i_sub, ai_source) = roi_area(i_sub, ai_source) + sum(t.rp.F.weight);
  end
end



return




for i_patch = 1:length(rs.a_patch)
  ai_patch = rs.a_patch(i_patch);
  for i_source = 1:length(rs.a_source)
    ai_source = rs.a_source(i_source);
    t.rp = rs.retinoPatch(ai_source, ai_patch);
    t.rp.F.com = t.rp.F.mean.norm; %For common condition
  end
end

%% Show Correlation Plots

figure(1); clf(1);
subplot(1,5,1:2); hold on;
colors = jet(length(a_patch));
for i_patch = 1:length(rs.a_patch) 
  ai_patch = rs.a_patch(i_patch);
  for i_source = 1:length(rs.a_source)
    ai_source = rs.a_source(i_source);
    t.rp = rs.retinoPatch(ai_source, ai_patch);

    M = max(t.rp.timefcn);
    m = min(t.rp.timefcn);
    plot((t.rp.timefcn-m)/(M-m)+t.rp.ind*.1+ai_source*4, 'o-', 'color', t.rp.faceColor);

    M = max(t.rp.timefcn_emp);
    m = min(t.rp.timefcn_emp);
    plot((t.rp.timefcn_emp-m)/(M-m)+2+t.rp.ind*.1+ai_source*4, '*-', 'color', t.rp.faceColor);
  end
end

for i_patch = 1:length(rs.a_patch)
  ai_patch = rs.a_patch(i_patch);
  for i_source = 1:length(rs.a_source)
    ai_source = rs.a_source(i_source);
    t.rp = rs.retinoPatch(ai_source, ai_patch);
    tt = corrcoef(reshape(V{ai_source}(1:n_kern,:)',1,n_kern*n_time), rp(ai_source, ai_patch).timefcn_emp);
    t.rp.sim.cor.emp = tt(1,2); 
    tt = corrcoef(reshape(V{ai_source}(1:n_kern,:)',1,n_kern*n_time), rp(ai_source, ai_patch).timefcn);
    t.rp.sim.cor.bem = tt(1,2);
  end
end

for i_source = 1:length(rs.a_source)
  ai_source = rs.a_source(i_source);
  subplot(1,5,2+ai_source);
  for i_patch = 1:length(rs.a_patch)
    ai_patch = rs.a_patch(i_patch);
    t.rp = rs.retinoPatch(ai_source, ai_patch);
    plot(ai_patch,t.rp.sim.cor.emp, '*', 'color', t.rp.faceColor); hold on;
    plot(ai_patch,t.rp.sim.cor.bem, 'o', 'color', t.rp.faceColor);
  end
  ylim([-1 1]);
  try
    xlim([1 numel(a_patch)]);
  end
end

set(171, 'Position', [10   100   1000   500])
set(171, 'Position', [-1000   519-32   921   485-32]);
set(gcf, 'Position', [-1000    32-32   921   403]);
return
%%
set(171, 'Position', [10   100   1600   900])
flatmap_str = sprintf('./pic/flatmap/flat_%s_%s', 'patch', subj_id);
set(171,'PaperUnits','inches','PaperPosition',[0 0 20 10])
saveas(171, flatmap_str, 'png');

set(171, 'Position', [10   100   1600   900])    
rplot.plot_flat_rois(171);
flatmap_str = sprintf('./pic/flatmap/flat_%s_%s', 'patch+roi', subj_id);
set(171,'PaperUnits','inches','PaperPosition',[0 0 20 10])
saveas(171, flatmap_str, 'png');

rplot.plot_flat_rois(172);
set(172, 'Position', [10   100   1600   900])
flatmap_str = sprintf('./pic/flatmap/flat_%s_%s', 'roi', subj_id);
set(172,'PaperUnits','inches','PaperPosition',[0 0 20 10])
saveas(172, flatmap_str, 'png');
% run('script_jitter_a');
% run('script_jitter_b');
% run('script_jitter_c');
%%
%options.outputDir = fullfile('html', sprintf('%gx%g_%g_src%g.html', rs.design.n_spokes, rs.design.n_rings, max(rs.a_patch), 3));
%publish('script_jitter_c.m', options)
