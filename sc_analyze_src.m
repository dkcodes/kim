close all;
% clearvars -regexp .* -except subj_id i_sub s_subj t_svd n_spoke n_ring n_patch a_source_accounted noise_level f roi_area dot_prod_1 stat
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
if exist('fwd_filename_sp', 'var')
    fwd_filename     = fullfile(dirs.mne, fwd_filename_sp);
    clear fwd_filename_sp;
else
    fwd_filename     = fullfile(dirs.mne, [subj_id '-fwd.fif']);
end
% sph_fwd_filename = fullfile(dirs.mne, [subj_id '-sph-fwd.fif']);

%% Environment preparations
if isempty(getappdata(0, 'fwd'))
  % To speed up loading very large data matrices
  disp('saving root variables');
  if ~exist('fwd', 'var')
    fwd=mne_read_forward_solution(fwd_filename);
    sph_fwd = '';
    %sph_fwd = mne_read_forward_solution(sph_fwd_filename);
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
rs.design       = design;
rs.a_patch      = a_patch;
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
rs.fill_fv();
r_pre                = retino_preproc(rs);
% cfg_corner_vert.type = 'patch';
% rs.fill_default_corner_vert(cfg_corner_vert);

%% Initialize patches
tic;
rs.init_session_patch();
rp = rs.retinoPatch;
rs.fill_rois_area();

%% Initialize and Process Data
clc;
clear rdata ans; rs.data = [];
rdata = retino_data(rs);
rs.data = rdata;
rdata.dir = subj_data.dir;
rdata.type = subj_data.type;
rdata.cfg.process_list = subj_data.process_list;
rdata.load_kernel();
rdata.process_data();
rdata.current = rdata.mean(:,:,:,130:300);
rdata.current = rdata.misc{1}(:,:,:,136:300);

%% Make Interactive Figure
figure(rs.h.main.fig); close(rs.h.main.fig);
clear rplot;
rplot       = retino_plotter(rs);
cfg.h_main  = rs.h.main.fig;
cfg.rs      = rs;
cfg.a_patch = [];%rs.a_patch;
rplot.cfg   = cfg;
rplot.plot_flat;
% rplot.plot_flat_rois;

%% Define Simulation parameters
% toggle_simdata          = 0;
% if isequal(toggle_simdata, 1)
%   cfg_sim      = p.cfg_sim;
%   cfg_sim.rs   = rs;                    %  Define simulation configuration
%   r_sim        = retino_sim(cfg_sim);   % Construct simulation object
%   rdata.mean   = r_sim.make_sim_data(); % Do Simulation
% %   rdata.mean   = randn(size(rdata.mean));
%   V            = rs.sim.true.timefcn;   % fill V with true V
%   clear VEP*
% end
%% Do source estimation
figure(1); clf(1);
try, delete(findobj(1, 'tag', 'svd')); end;
s_patch_def = {'left'  'up' 'outer' 'right' 'down'  'inner'};
for i_patch_def = 1:numel(s_patch_def)
    subplot(2,3,i_patch_def); hold on;
    pdef = s_patch_def{i_patch_def};
    rs.a_patch = patch_def.(pdef);
    rs.a_source = [1 2 3];
    rs.fill_session_patch_Vdata;
    rs.fill_ctf('meg', rs.a_patch);
    % rs.fill_session_patch_timefcn;
    % rs.fill_Femp('meg', rs.a_patch);
    % % rs.fill_ctf_Femp(rs.a_patch, 'meg');
    % rs.fill_session_patch_timefcn_emp;
    x = linspace(0, 406*1000/541, 406);
    plot(1:size(rs.ctf, 2), rs.ctf', 'linewidth', 2);
    tctf{i_patch_def} = rs.ctf';
    title(pdef)
%     
%     d=rdata.current(patch_def.(pdef),:,2,:);
%     n_1 = size(d,1); n_2 = size(d,2); n_3 = size(d,3); n_4 = size(d,4);
%     dd=reshape(d, n_1*n_2, n_4);
%     [u,s,t]=svd(dd,0);
%     uu = reshape(u, n_1, n_2, n_4);
%     if i_patch_def == 2
%         a_patch = rs.a_patch;
%         figure(100+i_patch_def); clf(100+i_patch_def);
%         for i_patch = 1:numel(a_patch)
%             if i_patch<49
%                 hold on;
%                 i_comp = 1;
%                 subplot(8,6,i_patch);  hold on;
%                 f = rp(1,a_patch(i_patch)).F.mean.norm';        f = f - min(f);        f = f/max(f);
%                 plotlayout2(f, 128, [0 0]);
%                 suu = squeeze(uu(i_patch,:,i_comp));        suu = (suu-min(suu));        suu = suu/max(suu);
%                 plotlayout2(suu, 128, [50 0]);
%                 title(num2str(a_patch(i_patch)));
%                 xlim([-25 75])
%             end
%         end
%         pause
%     end
%     
%     figure(1);
%     subplot(2,3,i_patch_def);
%     tt = t(:,1:3);
%     s1=tt(:,1)\tctf{i_patch_def}(:,1);
%     s2=tt(:,2)\tctf{i_patch_def}(:,2);
%     s3=tt(:,3)\tctf{i_patch_def}(:,3);
%     ttt = tt.*repmat([s1 s2 s3], size(tt,1), 1);
%     plot(ttt, '--', 'tag', 'svd')
end
legend('v1', 'v2', 'v3', 'c1', 'c2', 'c3')
return
%%

rs.a_patch = setdiff(1:96, [8    15    13    20    39]);
rs.a_patch = patch_def.all;
rs.a_source = [1 2 3];
rs.fill_session_patch_Vdata;
rs.fill_ctf('meg', rs.a_patch);
rs.fill_session_patch_timefcn;
rs.fill_Femp('meg', rs.a_patch);
% % rs.fill_ctf_Femp(rs.a_patch, 'meg');
% rs.fill_session_patch_timefcn_emp;
x = linspace(0, 406*1000/541, 406);
plot(x, rs.ctf', 'linewidth', 2);
tctf{i_patch_def} = rs.ctf';
title(pdef)

%%
clear d a;
a_patch = rs.a_patch;
a = zeros(96, 128, 1, 406);
a(a_patch,:,1,:)=rdata.v_model(a_patch,:,2,:)-rdata.current(a_patch,:,2,:);
a = a.^2;
a = squeeze(a);
for i = 1:96, d(i) = sum(sum(a(i,:,:))); end;

close all; clear dp ans; dp = dartboard_plotter(1:96); dp.make_dartboard(4,24,d)
