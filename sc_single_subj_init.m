clear
s_subj={
%   'skeri0001'
%   'skeri0004'
%   'skeri0009'
%   'skeri0017'
%   'skeri0035'
   'skeri0037'
%   %'skeri0039'
%   'skeri0044'
%   'skeri0048'
%   'skeri0050'
%   'skeri0051'
%   'skeri0053'
%   'skeri0054'
%   'skeri0060'
%   'skeri0066'
%   'skeri0069'
%   'skeri0071'
%   'skeri0072'
%   'skeri0075
%   'skeri0076'
%   'skeri0078'
%   'skeri0081'
  };
g.dirs = 'temp';
g.desc = sprintf('Comparing with Hood. Do svd as before, but only use 3 electrodes + a reference electrode at the inion. In Hood, the electrodes are placed in sagital (4cm +z) and transverse (4cm =-x) directions. For us, Standford data only has 128 channel electrodes which are 3 and 5 cm apart. We will pick the 5 cm apart electrodes, which should be more lenient for the SVD. The electrode #s at (inion: 81), (-x: 68), (+x: 94), (+z: 75).\n a_chan = [68 75 81 94] \n ref_chan = 81 \n Current v_amplitude = [1 1 1] \n a_patch = [patch_def.right]');
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
  run('sc_vis_sens_cortex');
end
this.dirs_out = fullfile('out', info.g.dirs, 'mat', 'stat.mat');
%save(this.dirs_out, 'stat');
