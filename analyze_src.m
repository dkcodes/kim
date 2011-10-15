clearvars -regexp [a-Z]* -except subj_id i_sub s_subj t_svd n_spokes n_rings n_patch a_source_accounted noise_level f roi_area dot_prod_1 stat
try, rmappdata(0, 'fwd'); end
close all;
% subj_id = 'skeri0001'; n_spokes = 4; n_rings =2; n_patch = n_spokes*n_rings; noise_level = 0; a_source_accounted = [1 2];
%n_spokes = 4; n_rings =2; n_patch = n_spokes*n_rings; noise_level = 0; a_source_accounted = [1 2];

% n_spokes    = 12;
% n_rings     = 4;          nPatch = n_spokes*n_rings; 
a_kern      = [1];


(1:n_spokes/2)

patches.left = repmat((1:n_spokes/2)',[1 n_rings])+repmat([0:n_rings-1]*n_spokes,[n_spokes/2 1]);
patches.up = repmat((1:n_spokes/2)',[1 n_rings])+repmat([0:n_rings-1]*n_spokes,[n_spokes/2 1]);
patches.down = patches.up(:)'+2;
patches.up = setdiff(1:n_spokes*n_rings, patches.down);
patches.right = repmat((1:n_spokes/2)',[1 n_rings])+repmat(n_spokes/2+[0:n_rings-1]*n_spokes,[n_spokes/2 1])
patches.all = [1:n_spokes*n_rings];
a_patch      = [patches.all];
a_source     = [1 2 3];


dirs.data      = getenv('ANATOMY_DIR');
dirs.fs4_data  = fullfile(dirs.data, 'FREESURFER_SUBS');
dirs.subj      = fullfile(dirs.fs4_data, [subj_id '_fs4']);
dirs.eeg       = fullfile(dirs.subj, [subj_id '_EEG']);
dirs.bem       = fullfile(dirs.eeg, 'bem');
dirs.mne       = fullfile(dirs.eeg, '_MNE_');
dirs.berkeley  = fullfile(dirs.data, 'Berkeley', subj_id);
fwd_filename   = fullfile(dirs.mne, [subj_id '-fwd.fif']);
sph_fwd_filename   = fullfile(dirs.mne, [subj_id '-sph-fwd.fif']);
%% Environment preparations
addpath('./lib');
add_lib();
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
   fwd         = getappdata(0, 'fwd');
   fwdtrue     = getappdata(0, 'fwdtrue');
end
%% Experiment and Analysis Parameters Declarations
megChan     = [1 60 120];    % all MEG
eegChan     = 129:200;  % 1:55 EEG
nDays       = 1;
time        = 1:30;
allChan     = megChan;
aDays       = 1;
s_rois.name      = {'V3D-L'    'V2D-L'    'V1D-L'    'V1V-L'    'V2V-L'    'V3V-L' ...
               'V3D-R'    'V2D-R'    'V1D-R'    'V1V-R'    'V2V-R'    'V3V-R'    };
s_rois.type = 'mesh';
nTime       = numel(time);
nAllChan    = length(allChan);
nSource     = length(a_source);
VEPavg = NaN(n_patch, nAllChan, nTime);

%% Define Session
rs = retino_session;

rs.dirs = dirs;
rs.subj_id = subj_id;
rs.rois = s_rois;

rs.design.n_spokes = n_spokes;
rs.design.n_rings  = n_rings;

rs.a_patch = a_patch;
rs.data.mean = VEPavg;
rs.chan = megChan;
rs.time = time;
rs.fwd = fwd;
rs.sph_fwd = sph_fwd;
rs.a_source = a_source;
rs.a_kern = a_kern;
rs.megChan = megChan;
rs.eegChan = eegChan;

rs.interpolate_fwd();
r_pre           = retino_preproc(rs);
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
rplot = retino_plotter;
cfg.rs = rs;
cfg.a_patch = [];%rs.a_patch;
rplot.cfg = cfg;
rplot.plot_flat;

%% Define Simulation parameters
% rs.a_kern = [1 2 3 4 5];
nKernels    = numel(rs.a_kern);
toggle_simdata = 1;
if toggle_simdata == 1
    cfg_sim.rs = rs;                    % Define simulation configuration
    cfg_sim.noise_level = noise_level;
    r_sim = retino_sim(cfg_sim);        % Construct simulation object
    VEPavg_sim = r_sim.make_sim_data(); % Do Simulation
    rs.data.mean = VEPavg_sim;          % fill rs.data.mean with simulated data
    V = rs.sim.true.timefcn;            % fill V with true V
end
rs.a_source = a_source_accounted;
rs.fill_session_patch_Vdata;

rs.fill_ctf(rs.a_patch, 'meg');
rs.fill_session_patch_timefcn;
rs.fill_Femp(rs.a_patch, 'meg');
% rs.fill_ctf_Femp(rs.a_patch, 'meg');
rs.fill_session_patch_timefcn_emp;
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
		tt = corrcoef(reshape(V{ai_source}(1:nKernels,:)',1,nKernels*nTime), rp(ai_source, ai_patch).timefcn_emp);
		t.rp.sim.cor.emp = tt(1,2); 
		tt = corrcoef(reshape(V{ai_source}(1:nKernels,:)',1,nKernels*nTime), rp(ai_source, ai_patch).timefcn);
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
