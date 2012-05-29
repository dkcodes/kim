function make_params(g, expt)
group_name = g.dirs;
list_group = g.list;
group_mat_folder = fullfile('.', 'in', 'param', group_name);
if isdir(group_mat_folder);
    str_overwrite = tsprintf('%s already exists. Overwrite? [y/n] ', group_mat_folder);
    flag_overwrite = input(str_overwrite,'s');
    if isequal(flag_overwrite, 'y')
        disp(sprintf('### OVER-WRITING existing parameter files ###'));
    else
        return;
    end
else
    if isequal(getenv('os'), 'Windows_NT')
        system(sprintf('mkdir %s', group_mat_folder));
        system(sprintf('mkdir %s', fullfile('.', 'out', group_name, 'fig' )));
        system(sprintf('mkdir %s', fullfile('.', 'out', group_name, 'mat' )));
    else
        system(sprintf('mkdir -p %s', group_mat_folder));
        system(sprintf('mkdir -p %s', fullfile('.', 'out', group_name, 'fig' )));
        system(sprintf('mkdir -p %s', fullfile('.', 'out', group_name, 'mat' )));
    end
end
for i_params = 1:numel(list_group)
    subj_id = list_group{i_params};
    expt.subj_id = subj_id;
    filename_params = fullfile(group_mat_folder, [subj_id '.mat']);
    make_individual_params(filename_params, expt);
end
filename_info = fullfile(group_mat_folder, 'info.mat');
save(filename_info, 'g');


function make_individual_params(filename, expt)
get_field(expt);
n_spoke = design.n_spoke;
n_ring = design.n_ring;
n_patch  = n_spoke*n_ring;
patch_def = make_patch_def(expt);
if isequal(class(a_patch), 'char')
    a_patch = patch_def.(a_patch);
end
save(filename)

function patch_def = make_patch_def(expt)
get_field(expt)
n_spoke = design.n_spoke;
n_ring = design.n_ring;
n_patch  = n_spoke*n_ring;
patch_def.all   = 1:n_patch;
patch_def.right = repmat((1:n_spoke/2)',[1 n_ring])+repmat([0:n_ring-1]*n_spoke,[n_spoke/2 1]);
patch_def.right = patch_def.right(:)';
patch_def.left  = setdiff(patch_def.all, patch_def.right);
patch_def.down  = patch_def.right+n_spoke/4;
patch_def.up    = setdiff(patch_def.all, patch_def.down);
patch_def.outer = 1:n_spoke*n_ring/2;
patch_def.inner = setdiff(1:n_spoke*n_ring, 1:n_spoke*n_ring/2);

patch_def.half_duty_on =[];
for i_ring = 1:n_ring
    array = ((i_ring-1)*n_spoke+1+mod(i_ring+1,2)):2:(i_ring)*n_spoke;
    patch_def.half_duty_on = [patch_def.half_duty_on array];
end
patch_def.half_duty_off =setdiff(patch_def.all, patch_def.half_duty_on);
    
