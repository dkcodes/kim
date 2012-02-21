clc
toggle_save    = 0;
toggle_restart = 1;
toggle_return  = 0;
if toggle_save
    for i = 1:length(rp)
        cv(i,:) = rp(i).hiResCornerVert;
    end
    save cv cv
    return
end

colors = jet(numel(rp)/nSource);
n_dir = 1;
n_move = 3;
for i_dir = 1:n_dir
    [x,y,z]=sph2cart(deg2rad(360/n_dir*(i_dir-1)), 0, 1);
    cfg.sim.dir(i_dir,:) = [x y z];
end


tic
for i=1:100, try, close(17000+i); end; end
for i_patch = 1:numel(rp); rp(i_patch).sim.cor = [];end
rs.aSource = [1 2];
rs.a_kern = [1 2];
nKernels = numel(rs.a_kern);
for i_dir = 1:n_dir
    if toggle_restart     
        for i_patch = 1:length(rs.aPatch)
            ai_patch = rs.aPatch(i_patch);
            for i_source = 1:length(rs.aSource)
                ai_source = rs.aSource(i_source);
                t.rp = rs.retinoPatch(ai_source, ai_patch);
                t.rp.hiResCornerVert = cv(ai_source, ai_patch).hiResCornerVert;
                t.rp.fill_surf_from_corner();
                t.rp.calculate_forward_hi(rs.fwd);
                F_true(ai_source, ai_patch,:) = rp(ai_source, ai_patch).F.mean.norm;
            end
        end
        for i = 1:numel(rp);rp(i).update_fig('surf');rp(i).update_fig('corner');end
        if toggle_return
            return
        end
    end
    
    for i_move= 1:n_move
        for i = 1:numel(rp);rp(i).update_fig('surf');rp(i).update_fig('corner');end
        disp(num2str([i_dir i_move]));      
        if i_move>1
        rs.jitter_session_pt_corner_dir(cfg.sim.dir(i_dir,:));
        end
        for i_patch = 1:numel(rp)
            rp(i_patch).fill_surf_from_corner();
            rp(i_patch).calculate_forward_hi(rp(i_patch).session.fwd);
        end
        rs.fill_ctf(rs.aPatch, 'meg');
        rs.fill_session_patch_timefcn;
        rs.fill_Femp(rs.aPatch, 'meg');
        rs.fill_session_patch_timefcn_emp;
        
        
        SSE_bem = zeros(length(rs.chan), length(rs.time)*length(rs.a_kern));
        SSE_emp = zeros(length(rs.chan), length(rs.time)*length(rs.a_kern));
        
        for i_patch = 1:length(rs.aPatch)
            ai_patch = rs.aPatch(i_patch);
            for i_source = 1:length(rs.aSource)
                ai_source = rs.aSource(i_source);
                t.rp = rs.retinoPatch(ai_source, ai_patch);
                
                tt = corrcoef(reshape(V{ai_source}(rs.a_kern,:)',1,nKernels*nTime), t.rp.timefcn_emp);
                t.rp.sim.cor.emp(i_move) = tt(1,2);
                
                tt = corrcoef(reshape(V{ai_source}(rs.a_kern,:)',1,nKernels*nTime), t.rp.timefcn);
                t.rp.sim.cor.bem(i_move) = tt(1,2);
                
                tt = corrcoef(rs.ctf(ai_source,:), t.rp.timefcn_emp);
                t.rp.sim.cor.ctf_emp(i_move) = tt(1,2);
                
                                
                SSE_bem = SSE_bem + (rs.concat_V_kern(t.rp)-t.rp.F.mean.norm*rs.ctf(ai_source,:)).^2;
                SSE_emp = SSE_emp + (rs.concat_V_kern(t.rp)-t.rp.Femp.mean.norm*t.rp.timefcn_emp).^2;
                
                tt = corrcoef(t.rp.Femp.mean.norm, F_true(ai_source, ai_patch,:));
                t.rp.sim.cor.F_emp_true(i_move) = tt(1,2);
                
                tt = corrcoef(t.rp.F.mean.norm, F_true(ai_source, ai_patch,:));
                t.rp.sim.cor.F_bem_true(i_move) = tt(1,2);
                
                tt = corrcoef(t.rp.F.mean.norm, t.rp.Femp.mean.norm);
                t.rp.sim.cor.F_bem_emp(i_move) = tt(1,2);
            end
        end
        SSE_bem_move(i_move) = sum(sum(SSE_bem));
        SSE_emp_move(i_move) = sum(sum(SSE_emp));
    end
    
    this.h.fig = 17000+i_dir;
    figure(this.h.fig); clf(this.h.fig);
    for i_source = 1:length(rs.aSource)
        ai_source = rs.aSource(i_source);
        for i_patch = 1:1:length(rs.aPatch)
            ai_patch = rs.aPatch(i_patch);
            t.rp = rs.retinoPatch(ai_source, ai_patch);
            subplot(3,max(rs.aSource),ai_source); hold on;
            plot(t.rp.sim.cor.ctf_emp, 's-', 'color', t.rp.faceColor, 'MarkerEdgeColor', 'r', 'LineWidth', 2)%, 'color', colors(i_patch,:));
            ylim([-1 1]);
            title(sprintf('Tcorr(T_{common}, T_{emp}) :: V%g', ai_source));
            xlabel('mm'); ylabel('corr');
%             plot(t.rp.sim.cor.bem, 'o-', 'color', t.rp.faceColor)%, 'color', colors(i_patch,:));
            subplot(3,max(rs.aSource),ai_source+max(rs.aSource)); hold on;
            plot(t.rp.sim.cor.F_emp_true, 'p-', 'color', t.rp.faceColor)%, 'color', colors(i_patch,:));
            ylim([-1 1])
            title(sprintf('Fcorr(F_{emp}, F_{true}) :: V%g', ai_source));
            xlabel('mm'); ylabel('corr');
        end
    end
    subplot(3,max(rs.aSource), rs.aSource+2*max(rs.aSource))
    hold on;
    plot(SSE_emp_move, 's-',  'MarkerEdgeColor', 'r', 'LineWidth', 2)%, 'color', colors(i_patch,:));
    plot(SSE_bem_move, 'o-')%, 'color', colors(i_patch,:));
    title(sprintf('V\\_SSE :: V%g', ai_source));
    legend('SSE_{bem}', 'SSE_{emp}', 'Location', 'NorthWest');
    set(gcf, 'Position', [3   278   634   697]);
    %    filename = sprintf('./pic/%g_%g_%g.png', noise_level, V12_ratio, i_dir);
    %    saveas(gcf, filename, 'png');
end