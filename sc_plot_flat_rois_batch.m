clear
s_subj={
%     'DK'
%    'skeri0001'   %1
%    'skeri0004'   %2
%    'skeri0009'   %3
%    'skeri0017'   %4
%    'skeri0035'   %5
% %    'skeri0037'   %6 Useable. But needs to make asc patch for parietal
% %    'skeri0039'
%    'skeri0044'   %6
%    'skeri0048'   %7
%    'skeri0050'   %8
%    'skeri0051'   %9
%    'skeri0053'   %10
%    'skeri0054'   %11
%    'skeri0060'   %12
   'skeri0066'   %13
%    'skeri0069'   %14
%    'skeri0071'   %15
%    'skeri0072'   %16
%    'skeri0075'   %17
%    'skeri0076'   %18
%    'skeri0078'   %19
%    'skeri0081'   %20
  };
g.dirs = 'tmp';
g.desc = sprintf('patch_def.outer \n 16x6 patches\n results_svd.mat\n 0.5 norm external source\n');
g.list = s_subj;

toggle_make_params = 1;
if toggle_make_params
  % Modify make_params.m to reflect experimental parameters.
  make_params(g);
end
 
info = load_params(fullfile('in', 'param', g.dirs, 'info.mat'));
for i_subj = 1:numel(s_subj)
  this.filename = fullfile ('in', 'param', info.g.dirs, info.g.list{i_subj});
  p = load_params(this.filename); %#ok<*NASGU>
  run('sc_analyze_src');
  run('sc_svd');
  if i_subj == 1
    set_data_average = zeros(size(rs.data.mean));
  end
  set_data_average = set_data_average + rs.data.mean;
%  run('sc_vis_sens_cortex');
end
v_all = reshape(set_data_average(rs.a_patch, rs.a_chan,:,:), numel(rs.a_patch)*numel(rs.a_chan), numel(rs.a_time));
[u, s, t] = svd(v_all);
fh_corr = @(x) x(2);
corr_Vens_SVD(1) = fh_corr(corrcoef(rs.sim.true.timefcn{1}, t(:,1)));
corr_Vens_SVD(2) = fh_corr(corrcoef(rs.sim.true.timefcn{2}, t(:,2)));
if numel(rs.a_source > 2)
  corr_Vens_SVD(3) = fh_corr(corrcoef(rs.sim.true.timefcn{3}, t(:,3)));
end
results_svd(1).corr_Vens_SVD = corr_Vens_SVD;
results_svd(1).set_data_average = set_data_average;
results_svd(1).svd.all.u = u(:, 1:5);
results_svd(1).svd.all.s = s(:, 1:5);
results_svd(1).svd.all.t = t(:, 1:5);

this.dirs_out = fullfile('out', info.g.dirs, 'mat', 'results_svd.mat');
save(this.dirs_out, 'results_svd');
