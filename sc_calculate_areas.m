% clear
% s_subj={
%     %     'DK'
%     'skeri0001'   %1
%     'skeri0004'   %2
%     'skeri0009'   %3
%     'skeri0017'   %4
%     'skeri0035'   %5
%     %     'skeri0037'   %6 Useable. But needs to make asc patch for parietal
% %     'skeri0039'
%     'skeri0044'   %7
%     'skeri0048'   %8
%     'skeri0050'   %9
%     'skeri0051'   %10
%     'skeri0053'   %11
%     'skeri0054'   %12
%     'skeri0060'   %13
%     'skeri0066'   %14
%     'skeri0069'   %15
%     'skeri0071'   %16
%     'skeri0072'   %17
%     'skeri0075'   %18
%     'skeri0076'   %19
%     'skeri0078'   %20
%     'skeri0081'   %21
%     };
% g.dirs = 'paper_svd_calculate_area';
% g.desc = sprintf('patch_def.all \n 24x4 patches\n Used to calculate');
% g.list = s_subj;
% 
% toggle_make_params = 0;
% if toggle_make_params
%     % Modify make_params.m to reflect experimental parameters.
%     make_params(g);
% end
% 
% info = load_params(fullfile('in', 'param', g.dirs, 'info.mat'));
% for i_subj = 1:numel(s_subj)
%     this.filename = fullfile ('in', 'param', info.g.dirs, info.g.list{i_subj});
%     p = load_params(this.filename); %#ok<*NASGU>
%     run('sc_analyze_src');
%     for i_patch = a_patch
%         for i_src = a_source
%             patch_areas(i_subj, i_src, i_patch) = sum(rp(i_src, i_patch).F.weight)*1e6;
%         end
%     end
% end

%% statistics
% load('E:\raid\MRI\toolbox\kim\in\param\paper_svd_statistics_parietal\info.mat')
% load('E:\raid\MRI\toolbox\kim\out\paper_svd_calculate_area\mat\patch_areas.mat')
n_spoke = 16; % needs > 4 (Left, right, up, down)
n_ring  = 6;
n_patch  = n_spoke*n_ring;

patch_def.all   = [1:n_spoke*n_ring];
patch_def.right = repmat((1:n_spoke/2)',[1 n_ring])+repmat([0:n_ring-1]*n_spoke,[n_spoke/2 1]);
patch_def.right = patch_def.right(:)';
patch_def.left  = setdiff(patch_def.all, patch_def.right);
patch_def.down  = patch_def.right+n_spoke/4;
patch_def.up    = setdiff(patch_def.all, patch_def.down);
patch_def.outer = 1:n_spoke*n_ring/2;
patch_def.inner = setdiff(1:n_spoke*n_ring, 1:n_spoke*n_ring/2);

patch_def.LV = intersect(patch_def.right, patch_def.up);  % Left Hemi, Ventral
patch_def.LD = intersect(patch_def.right, patch_def.down);
patch_def.RV = intersect(patch_def.left, patch_def.up);
patch_def.RD = intersect(patch_def.left, patch_def.down);


summary_mat = [];
for i_subject = 1:numel(g.list)
    active_areas(i_subject).RV(a_source) = 0;
    active_areas(i_subject).RD(a_source) = 0;
    active_areas(i_subject).LV(a_source) = 0;
    active_areas(i_subject).LD(a_source) = 0;
    
    for i_src = a_source
        for i_patch = patch_def.RV
            active_areas(i_subject).RV(i_src) = active_areas(i_subject).RV(i_src) + sum(results_svd(i_subject).true.F(i_src, i_patch).weight)*1e6;
        end
        for i_patch = patch_def.RD
            active_areas(i_subject).RD(i_src) = active_areas(i_subject).RD(i_src) + sum(results_svd(i_subject).true.F(i_src, i_patch).weight)*1e6;
        end
        for i_patch = patch_def.LV
            active_areas(i_subject).LV(i_src) = active_areas(i_subject).LV(i_src) + sum(results_svd(i_subject).true.F(i_src, i_patch).weight)*1e6;
        end
        for i_patch = patch_def.LD
            active_areas(i_subject).LD(i_src) = active_areas(i_subject).LD(i_src) + sum(results_svd(i_subject).true.F(i_src, i_patch).weight)*1e6;
        end
    end

    summary_mat((i_subject-1)*2+1, :) = [active_areas(i_subject).RV active_areas(i_subject).RD active_areas(i_subject).RD+active_areas(i_subject).RV];
    summary_mat((i_subject-1)*2+2, :) = [active_areas(i_subject).LV active_areas(i_subject).LD active_areas(i_subject).LD+active_areas(i_subject).LV];
end
%%
        aa1 = active_areas(i_subject).all(1);
        aa2 = active_areas(i_subject).all(2);
        aa3 = active_areas(i_subject).all(3);
        fprintf('Subject %2g : %6.2f %6.2f %6.2f : %6.1f %6.1f %6.1f\n', ...
            i_subject, aa1, aa2, aa3,...
            aa1/aa1, aa2/aa1, aa3/aa1...
            )
        
end

areas=reshape([active_areas(:).all],3,20)';
areas_sum1 = mean(areas(1:9,:));
areas_sum2 = mean(areas(10:end,:));
areas_sum = mean(areas(1:9,:))
areas_sum1/areas_sum1(1);
areas_sum2/areas_sum2(1);
areas_sum/areas_sum(1)

for i = 1:20, fprintf('%2.2f\n', areas(i,1)); end
disp(' ')
for i = 1:20, fprintf('%2.2f\n', areas(i,2)); end
disp(' ')
for i = 1:20, fprintf('%2.2f\n', areas(i,3)); end