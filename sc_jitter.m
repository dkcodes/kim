cv_filename = fullfile('in', 'param', g.dirs, 'cv.mat');

toggle_save    = 1;
toggle_restart = 1;
toggle_return  = 0;
if toggle_save
    clear cv
    for i_src = rs.a_source
        for i_patch = 1:numel(rs.a_patch)
            ai_patch = rs.a_patch(i_patch);
            t.rp = rp(i_src, ai_patch);
            cv(i_src, i_patch).hiResCornerVert = rp(i_src, ai_patch).hiResCornerVert;
        end
    end
    save(cv_filename, 'cv')
end

n_dir = 1;
n_move = 1;
for i_dir = 1:n_dir
    [x,y,z]=sph2cart(deg2rad(360/n_dir*(i_dir-1)), 0, 1);
    cfg.sim.dir(i_dir,:) = [x y z];
end

for i_dir = 1:n_dir
    if toggle_restart     
        load(cv_filename)
        for i_patch = 1:numel(rs.a_patch)
            ai_patch = rs.a_patch(i_patch);
            for i_source = 1:length(rs.a_source)
                ai_source = rs.a_source(i_source);
                t.rp = rs.retinoPatch(ai_source, ai_patch);
                t.rp.hiResCornerVert = cv(ai_source, ai_patch).hiResCornerVert;
                t.rp.fill_surf_from_corner();
                t.rp.calculate_forward_hi();
            end
        end
        if toggle_return
            return
        end
    end

    for i_move= 1:n_move
        disp(num2str([i_dir i_move]));      
        if i_move>1
            rs.jitter_session_pt_corner_dir(cfg.sim.dir(i_dir,:));
        end
        for i_patch = 1:numel(rp)
            rp(i_patch).fill_surf_from_corner();
            rp(i_patch).calculate_forward_hi();
        end
        rs.fill_ctf(rs.a_patch, 'meg');
        rs.fill_session_patch_timefcn;
        rs.fill_Femp(rs.a_patch, 'meg');
        rs.fill_session_patch_timefcn_emp;





        results_ind(i_dir, i_move).results_svd(i_subj).subj_id = subj_id;
        temp.data = rs.data.mean;
        n_patch = size(temp.data,1);
        n_sens  = size(temp.data,2);
        n_kern  = size(temp.data,3);
        n_time  = size(temp.data,4);
        n_chan  = numel(rs.a_chan);

        data = [];
        for i_patch = 1:numel(rs.a_patch)
            ai_patch = rs.a_patch(i_patch);
            this.rp = rp(1, ai_patch);
            for i_kern = 1:size(temp.data,3)
                data = [data; rs.concat_V_kern(this.rp)];
            end
        end
        clc
        %[u,s,t] = svd(data);
        u = rand(n_chan, n_chan);
        s = rand(n_chan, n_chan);
        t = rand(n_time, n_time);
        t_svd{i_subj}= t(:,1:3);

        alternate_components = [2 1 3];
        for i_source = rs.a_source
            tt = corrcoef(t(:,i_source), V{i_source}); 
            corr_VSVD(i_source) = tt(1,2);
            tt = corrcoef(t(:,alternate_components(i_source)), V{i_source}); 
            corr_VSVD2(i_source) = tt(1,2);
        end
        if abs(corr_VSVD(1)) < abs(corr_VSVD2(1))
            results_ind(i_dir, i_move).results_svd(i_subj).svd.T_all.corr = round(abs(100*corr_VSVD2))+abs(corr_VSVD);
        else
            results_ind(i_dir, i_move).results_svd(i_subj).svd.T_all.corr = corr_VSVD;
        end
        results_ind(i_dir, i_move).results_svd(i_subj).svd.T_all.corr

        for i_source = rs.a_source
            tt = corrcoef(rs.ctf(i_source,:), V{i_source}); 
            corr_VCTF(i_source) = tt(1,2);
        end
        results_ind(i_dir, i_move).results_svd(i_subj).true.T_all.corr = corr_VCTF;

        results_ind(i_dir, i_move).results_svd(i_subj).true.data.t = rs.sim.true.timefcn;
        results_ind(i_dir, i_move).results_svd(i_subj).svd.data.u = u(:,1:3);
        results_ind(i_dir, i_move).results_svd(i_subj).svd.data.s = s(1:3,1:3);
        results_ind(i_dir, i_move).results_svd(i_subj).svd.data.t = t(:,1:3);

        for i_src = rs.a_source
            for i_patch = 1:numel(rs.a_patch)
                ai_patch = rs.a_patch(i_patch);
                results_ind(i_dir, i_move).results_svd(i_subj).true.data.patch{i_src, i_patch} = rp(i_src, ai_patch).timefcn;
                results_ind(i_dir, i_move).results_svd(i_subj).true.T.corr.patch(i_src, i_patch) = corr(rs.sim.true.timefcn{i_src}', rp(i_src, ai_patch).timefcn');
            end
        end

        F_all =[];
        for i_patch = 1:numel(rs.a_patch)
            ai_patch = rs.a_patch(i_patch);
            F = []; UF = [];
            for i_source = rs.a_source
                F(:,i_source) = rp(i_source, ai_patch).F.mean.norm;
                UF(:,i_source) = u(:,i_source);
            end
            F_all = [F_all; F];
            UF_all = UF;

            for i_source = rs.a_source
                results_ind(i_dir, i_move).results_svd(i_subj).true.F(ai_patch).sum(i_source) = ...
                    F(:, i_source)' * F(:, i_source);
                results_ind(i_dir, i_move).results_svd(i_subj).svd.F(ai_patch).sum(i_source) = ...
                    UF(:, i_source)' * UF(:, i_source);
                for j_source = rs.a_source
                    results_ind(i_dir, i_move).results_svd(i_subj).true.F(ai_patch).angles(i_source, j_source) = ...
                        subspace( F(:, i_source), F(:, j_source) );
                    results_ind(i_dir, i_move).results_svd(i_subj).svd.F(ai_patch).angles(i_source, j_source) = ...
                        subspace( UF(:, i_source), UF(:, j_source) );
                end
            end
        end
        for i_source = rs.a_source
            results_ind(i_dir, i_move).results_svd(i_subj).true.F_all.sum = ...
                F_all(:, i_source)' * F_all(:, i_source);
            results_ind(i_dir, i_move).results_svd(i_subj).svd.F_all.sum = ...
                UF_all(:, i_source)' * UF_all(:, i_source) ;
            for j_source = rs.a_source
                results_ind(i_dir, i_move).results_svd(i_subj).true.F_all.angles(i_source, j_source) = ...
                    subspace( F_all(:, i_source), F_all(:, j_source) );
                results_ind(i_dir, i_move).results_svd(i_subj).svd.F_all.angles(i_source, j_source) = ...
                    subspace( UF_all(:, i_source), UF_all(:, j_source) );
            end
        end
        results_ind(i_dir, i_move).results_svd(i_subj).svd.F_all.data = UF_all;
        results_ind(i_dir, i_move).results_svd(i_subj).true.F_all.data = F_all;

        for i_patch = 1:numel(rs.a_patch)
            ai_patch = rs.a_patch(i_patch);
            if max(rs.a_source) > 2
                temp_angles(i_patch, :) = results_ind(i_dir, i_move).results_svd(i_subj).true.F(ai_patch).angles([2 3 6]);
            else
                temp_angles(i_patch, :) = results_ind(i_dir, i_move).results_svd(i_subj).true.F(ai_patch).angles([2]);
            end
        end
        results_ind(i_dir, i_move).results_svd(i_subj).true.F_all.mean_angles = mean(temp_angles);

        results_ind(i_dir, i_move).results_svd(i_subj).summary.corr_V_SVD = results_ind(i_dir, i_move).results_svd(i_subj).svd.T_all.corr;
        if max(rs.a_source) > 2
            results_ind(i_dir, i_move).results_svd(i_subj).summary.F_all_ang = rad2deg(results_ind(i_dir, i_move).results_svd(i_subj).true.F_all.angles([2 3 6]));
        else
            results_ind(i_dir, i_move).results_svd(i_subj).summary.F_all_ang = rad2deg(results_ind(i_dir, i_move).results_svd(i_subj).true.F_all.angles([2]));
        end
        results_ind(i_dir, i_move).results_svd(i_subj).summary.F_ang_mean = rad2deg(results_ind(i_dir, i_move).results_svd(i_subj).true.F_all.mean_angles);
        results_ind(i_dir, i_move).results_svd(i_subj).summary.abs_area = rs.rois.weight.visual_areas;
        results_ind(i_dir, i_move).results_svd(i_subj).summary.eff_area = rs.rois.weight.effective_visual_areas;
        results_ind(i_dir, i_move).results_svd(i_subj).summary.corr_V_CTF = corr_VCTF;
        results_ind(i_dir, i_move).results_svd(i_subj).p = p;
        clear t
    end
end
return

