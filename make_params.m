function make_params(g)
  group_name = g.dirs;
  list_group = g.list;
  group_mat_folder = fullfile('.', 'in', 'param', group_name);
  if isdir(group_mat_folder);
    str_overwrite = sprintf(...
      '%s already exists. Overwrite? [y/n] ', group_mat_folder);
    flag_overwrite = input(str_overwrite,'s');
    if isequal(flag_overwrite, 'y')
      disp(sprintf('### OVER-WRITING existing parameter files ###'));
    else
      return;
    end
  else
    system(sprintf('mkdir -p %s', group_mat_folder));
    system(sprintf('mkdir -p %s', fullfile('.', 'out', group_name, 'fig' )));
    system(sprintf('mkdir -p %s', fullfile('.', 'out', group_name, 'mat' )));
  end
  for i_params = 1:numel(list_group)
    subj_id = list_group{i_params};
    filename_params = fullfile(group_mat_folder, [subj_id '.mat']);
    make_individual_params(filename_params, subj_id);
  end
  save(fullfile(group_mat_folder, 'info.mat'), 'g');


function make_individual_params(filename, subj_id, auth)
  n_spokes = 16; % needs > 4 (Left, right, up, down)
  n_rings  = 6;
  n_patch  = n_spokes*n_rings;

  patch_def.all   = [1:n_spokes*n_rings];
  patch_def.right = repmat((1:n_spokes/2)',[1 n_rings])+repmat([0:n_rings-1]*n_spokes,[n_spokes/2 1]);
  patch_def.right = patch_def.right(:)';
  patch_def.left  = setdiff(patch_def.all, patch_def.right);
  patch_def.down  = patch_def.right+n_spokes/4;
  patch_def.up    = setdiff(patch_def.all, patch_def.down);

  meg_chan           = 1:128;    % all MEG
  eeg_chan           = 129:200;  % 1:55 EEG
  ref_chan           = 75;
  a_patch            = [patch_def.all];
  a_source           = [1 2 3];
  a_source_accounted = [1 2 3];
  a_kern             = [1];
  a_time             = 1:100;
  a_chan             = [62 65 75 90]; %[68 75 81 94];
%  a_chan             = [68 75 81 94];
  a_chan             = [1:128];
  a_days             = 1;

  cfg_sim.ref_chan      = ref_chan;
  cfg_sim.v_amplitude   = [1.25 1 1];
  cfg_sim.src_time_type = 'thom';
  cfg_sim.f_type        = '';


  s_rois.name        = {'V3D-L'    'V2D-L'    'V1D-L'    'V1V-L'    'V2V-L'    'V3V-L' ...
    'V3D-R'    'V2D-R'    'V1D-R'    'V1V-R'    'V2V-R'    'V3V-R'    };
  s_rois.type  = 'mesh';
  save(filename)
