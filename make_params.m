function p = make_params(p_auth)
if ~exist('toggle_svd_batch', 'var')
  p.subj_id = 'skeri0001'; 
  n_spokes = 16; p.n_spokes = n_spokes;
  n_rings = 4;   p.n_rings  = n_rings;
  p.n_patch = p.n_spokes*p.n_rings; 
  p.noise_level = 0; 
  p.a_source_accounted = [1 2];
end
patches.all   = [1:n_spokes*n_rings];
patches.right = repmat((1:n_spokes/2)',[1 n_rings])+repmat([0:n_rings-1]*n_spokes,[n_spokes/2 1]);
patches.right = patches.right(:)';
patches.left  = setdiff(patches.all, patches.right);
patches.down  = patches.right+n_spokes/4;
patches.up    = setdiff(patches.all, patches.down);
p.patches = patches;

p.meg_chan     = [1 60 120];    % all MEG
p.eeg_chan     = 129:200;  % 1:55 EEG
p.a_patch      = [patches.left];
p.a_source     = [1 2];
p.a_kern       = [1];
p.a_time       = 1:30;
p.a_chan       = p.meg_chan;
p.a_days       = 1;
p.s_rois.name  = {'V3D-L'    'V2D-L'    'V1D-L'    'V1V-L'    'V2V-L'    'V3V-L' ...
                'V3D-R'    'V2D-R'    'V1D-R'    'V1V-R'    'V2V-R'    'V3V-R'    };
p.s_rois.type  = 'mesh';
