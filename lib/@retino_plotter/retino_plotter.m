classdef retino_plotter < handle
    properties
        cfg
    end %k
    methods
        function obj=retino_plotter()
        end %k
        function update(obj)
            rs = obj.cfg.rs;
            for i_patch = 1:numel(rs.a_patch)
                ai_patch = rs.a_patch(i_patch);
                for i_source = 1:length(rs.a_source)
                    ai_source = rs.a_source(i_source);
                    t.rp = rs.retinoPatch(ai_source, ai_patch);
                    t.rp.update_fig('surf');
                    t.rp.update_fig('corner');
                end
            end
        end %k
        function plot_flat(obj)
            rs = obj.cfg.rs;
            rp = rs.retinoPatch;
            h.fig = 171;
            figure(h.fig); clf(h.fig);
            
            subplot(1,2,1); hold on; axis equal square;
            %          patch('Faces', rs.lh.flat.tris, 'Vertices', rs.lh.flat.vert_full(:,2:4), 'EdgeColor', [.65 .65 .65], 'FaceColor', 'w');
            i_not_nan = ~isnan(rs.lh.flat.vert_full(:,2));
            rs.lh.h.nodes = plot(rs.lh.flat.vert_full(i_not_nan,2), rs.lh.flat.vert_full(i_not_nan,3), '.');
            set(rs.lh.h.nodes, 'color', [ .6 .6 .6], 'HitTest', 'on', 'Tag', 'nodes');
            subplot(1,2,2); hold on; axis equal square;
            rs.rh.h.nodes = plot(rs.rh.flat.vert_full(:,2), rs.rh.flat.vert_full(:,3), '.');
            set(rs.rh.h.nodes, 'color', [ .6 .6 .6], 'HitTest', 'on', 'Tag', 'nodes');
            %          patch('Faces', rs.rh.flat.tris, 'Vertices', rs.rh.flat.vert_full(:,2:4), 'EdgeColor', [.65 .65 .65], 'FaceColor', 'w');
            for i_source = 1:3%rs.a_source
                for i_patch = rs.a_patch
                    try
                        t.rp = rp(i_source, i_patch);
                        switch t.rp.hemi
                            case 'L'
                                subplot(1,2,1);
                                flat = rs.lh.flat;
                                %                                 xlim([-40 30]);  ylim([-10 40]);
                            case 'R'
                                subplot(1,2,2);
                                flat = rs.rh.flat;
                                %                                 xlim([0 60]);  ylim([-40 30]);
                            otherwise
                                error('Unknown Hemisphere');
                        end
                        vert_full = flat.vert_full;
                        rp(i_source, i_patch).h.surf   = plot(vert_full(rp(i_source, i_patch).hiResVert,2), vert_full(rp(i_source, i_patch).hiResVert,3),'o');
                        set(rp(i_source, i_patch).h.surf, 'LineWidth', 2, 'color', rp(i_source, i_patch).faceColor, 'HitTest', 'off', 'Tag', 'surf');
                        rp(i_source, i_patch).h.corner = plot(vert_full(rp(i_source, i_patch).hiResCornerVert,2), vert_full(rp(i_source, i_patch).hiResCornerVert,3), 'sk');
                        set(rp(i_source, i_patch).h.corner, 'MarkerSize', 5, 'MarkerFaceColor', [0 0 0], 'HitTest', 'on', 'Tag', 'corner');
                        text(mean(vert_full(rp(i_source, i_patch).hiResVert,2)), mean(vert_full(rp(i_source, i_patch).hiResVert,3)), ...
                            sprintf('%g', rp(i_source, i_patch).ind), 'FontSize', 20);
                    end
                end
            end
            setappdata(h.fig, 'rs', rs);
            set(h.fig,'WindowButtonDownFcn',{@mouseDownFcn});
            set(h.fig,'WindowKeyPressFcn',{@keyDownFcn});
        end %k
        function plot_flat_retino(obj, i_scan, range) 
            
            data_type = 'ph';
            
            rs = obj.cfg.rs;
            h.fig = 171;
            figure(h.fig);
            colormap(copper(100))
            
            s_hemi = {'lh' 'rh'}; 
            for i_hemi = 1:numel(s_hemi)
                hemi = s_hemi{i_hemi};
                subplot(1,2,i_hemi); hold on; axis equal square;
                set(gca,'xdir','reverse')
                
                vert = rs.(hemi).flat.vert_full;
                if isequal(i_hemi, 1) %% temporary. Sometimes these flat verts have outliers and needs manual deletion
                    i_not_nan = ~isnan(vert(:,2)) & vert(:,2)<40 & vert(:,3)<50;
                else
                    i_not_nan = ~isnan(vert(:,2));
                end
                if exist('i_scan', 'var')
                    w = rs.fmri.mrv.(data_type).(hemi){i_scan};
                else
                    w = rs.fmri.(hemi).(data_type);
                end
                if exist('range', 'var')
                    i_range = w>range(1) & w<range(2);
                    w = ones(size(w));
                    w(~i_range)=0;
                end

                x = vert(i_not_nan,2);
                y = vert(i_not_nan,3);
                w = w(i_not_nan);
                [Xq Yq] = meshgrid(linspace(min(x),max(x),60), linspace(min(y),max(y),60));             
                F = TriScatteredInterp(x, y, w');
                Vq = F(Xq, Yq);
%                 Vq = imfilter(Vq, fspecial('gaussian', 3, 1));
                try, delete(rs.h.retino.(hemi)); end;
                [junk, rs.h.retino.(hemi)]=contour(Xq, Yq, Vq, 'fill', 'on');
                set(rs.h.retino.(hemi), 'LevelStep', 0.2)
            end
        end %k
        function plot_flat_rois(obj, h_fig)
            rs = obj.cfg.rs;
            src = rs.fwd.src;
            rois = rs.rois.name;
            colors = jet(numel(rois));
            h.fig = 171;
            if nargin==2
                h.fig = h_fig;
            end
            try
                hAx = findobj(h.fig,'type','axes');
                figure(h.fig);
                subplot(1,2,1); hold on; subplot(1,2,2); hold on;
                hAx = findobj(h.fig,'type','axes');
            catch
                figure(h.fig);
                subplot(1,2,1); hold on; axis square equal;
                subplot(1,2,2); hold on; axis square equal;
                hAx = findobj(h.fig,'type','axes');
            end
            
            cfg.fwd = rs.fwd;
            cfg.cortexType = 'hires';
            cfg.thresh = 1;
            cfg.fWhite2Pial = .5;
            cfg.vAnatFile = fullfile(rs.dirs.subj, 'vAnatomy.dat');
            cfg.mrmFile   = fullfile(rs.dirs.berkeley, 'default_cortex.mat');
            cfg.roiDir    = fullfile(rs.dirs.subj, 'Standard', 'Gray', 'ROIs');
            
            for i_roi = 1:numel(rois)
                cfg.ROIfiles = [rois{i_roi} '.mat'];
                hemi = cfg.ROIfiles(end-4);
                if isequal(rs.rois.type, 'Gray')
                    aMap = MLRrois2meshDK(cfg);
                    if isequal(hemi, 'L')
                        aMap=aMap(aMap<=src(1).np);
                        rs.rois.(regexprep(rois{i_roi}, '-', '_')) = aMap;
                    elseif isequal(hemi, 'R')
                        aMap=aMap(aMap>src(1).np)-double(src(1).np);
                        rs.rois.(regexprep(rois{i_roi}, '-', '_')) = aMap;
                    else
                        error('Unknown Hemisphere');
                    end
                else
                    roiDir    = fullfile(rs.dirs.subj, 'Standard', 'meshes', 'ROIs');
                    load(fullfile(roiDir, rois{i_roi}))
                    %                         load(fullfile(rs.dirs.bem, sprintf('%s_fs4-ico-5p-patches.w.mat', rs.subj_id)));
                    if isequal(hemi, 'L')
                        i_src = 1;
                        offset = 0;
                        %                         aMap = rs.fwd.src(1).vertno(ROI.meshIndices);
                    elseif isequal(hemi, 'R')
                        i_src = 2;
                        offset = 10242;
                        %aMap = rs.fwd.src(2).vertno(ROI.meshIndices - 10242);
                    else
                        error('Unknown Hemisphere');
                    end
                    rs.rois.data(i_roi).lo_res = ROI.meshIndices;
                    i_src_hi_res = [rs.sph_fwd.src(i_src).pinfo{ROI.meshIndices - offset}];
                    isequal([rs.fwd.src(i_src).pinfo{ROI.meshIndices-offset}], [rs.sph_fwd.src(i_src).pinfo{ROI.meshIndices-offset}])
                    rs.rois.data(i_roi).hi_res = i_src_hi_res;
                    patch_stat(1, i_roi).hemi = hemi;
                    patch_stat(1, i_roi).subj_id = rs.subj_id;
                    patch_stat(1, i_roi).area=sum(w(i_src).data(i_src_hi_res));
                    rs.sim.patch_stat = patch_stat;
                    
                    
                    [a,b]=ismember(rs.sph_fwd.src(i_src).vertno, rs.fwd.src(i_src).vertno);
                    sph.ROI.meshIndices = b(ROI.meshIndices - offset);
                    sph.ROI.meshIndices = sph.ROI.meshIndices(sph.ROI.meshIndices~=0);
                    aMap = rs.fwd.src(i_src).vertno(sph.ROI.meshIndices);
                end
                marker_shape  = {'.' 'o' '+' 'p' 'x' '>'};
                marker_shape  = {'+' '^' 'x' '^' '+' '^'};
                line_width = [2 2 2 2 2 2];
                roi_name = regexprep(rs.rois.name{i_roi}, '-', '_');
                
                tog_display_perimeter = 0;
                switch hemi
                    case 'L'
                        %                         aMap=aMap(aMap<=src(1).np);
                        [cfg.hiResMeshPointsWithForward, cfg.vertnoIndex]=intersect(src(1).vertno,aMap);
                        v = rs.lh.flat.vert_full;
                        set(h.fig, 'CurrentAxes', hAx(2));
                        x = v(aMap,2);
                        y = v(aMap,3);
                        roi_name = regexprep(rs.rois.name{i_roi}, '-', '_');
                        if ~tog_display_perimeter
                            h.rois.(roi_name).p = plot(x,y,'.','color', colors(i_roi,:));
                            
                            if isequal(rs.rois.name{i_roi}(2), '3')
                                h.rois.(roi_name).text = text(mean(x), min(v(:,3)), rs.rois.name{i_roi}(end-2), 'fontsize', 30, 'color', 'k');
                            end
                        else
                            hull_points = convhull(x,y);
                            rs.lh.flat.perimeter.(roi_name)(:,1) = x(hull_points);
                            rs.lh.flat.perimeter.(roi_name)(:,2) = y(hull_points);
                            plot(x(hull_points) , y(hull_points), 'linewidth', 2 );
                        end
                        try
                            axis equal;
                            set(h.rois.(roi_name), 'Marker', marker_shape{i_roi}, 'LineWidth', line_width(i_roi));
                        end
                    case 'R'
                        %                         aMap=aMap(aMap>src(1).np)-double(src(1).np);
                        [cfg.hiResMeshPointsWithForward, cfg.vertnoIndex]=intersect(src(2).vertno,aMap);
                        v = rs.rh.flat.vert_full;
                        set(h.fig, 'CurrentAxes', hAx(1));
                        x = v(aMap,2);
                        y = v(aMap,3);
                        if ~tog_display_perimeter
                            h.rois.(roi_name).p = plot(x,y,'.','color', colors(i_roi,:));
                            if isequal(rs.rois.name{i_roi}(2), '3')
                                h.rois.(roi_name).text = text(mean(x), min(v(:,3)), rs.rois.name{i_roi}(end-2), 'fontsize', 30, 'color', 'k');
                            end
                        else
                            hull_points = convhull(x,y);
                            rs.rh.flat.perimeter.(roi_name)(:,1) = x(hull_points);
                            rs.rh.flat.perimeter.(roi_name)(:,2) = y(hull_points);
                            plot(x(hull_points) , y(hull_points), 'linewidth', 2 );
                        end
                        try
                            axis equal;
                            set(h.rois.(roi_name), 'Marker', marker_shape{i_roi-numel(rois)/2}, ...
                                'LineWidth', line_width(i_roi-numel(rois)/2));
                        end
                end
            end
            try
            rs.h.rois = h.rois;
            end
            setappdata(h.fig, 'rs', rs);
        end %k
        function plot_3D(obj)
            figure(11223344);
            rs = obj.cfg.rs;
            a_patch = obj.cfg.a_patch;
            
            for i_patch = 1:length(a_patch)
                ai_patch = a_patch(i_patch);
                for i_source = 1:length(rs.a_source)
                    ai_source = rs.a_source(i_source);
                    t.rp = rs.retinoPatch(ai_source, ai_patch);
                    if t.rp.hemi == 'L'
                        if obj.cfg.n_subplot == 1
                            subplot(1,1,1); hold on;
                        else
                            subplot(1,2,2); hold on;
                        end
                        fv =  rs.lh.midgray.fv;
                        src = rs.fwd.src(1);
                    else
                        
                        if obj.cfg.n_subplot == 1
                            subplot(1,1,1); hold on;
                        else
                            subplot(1,2,2); hold on;
                        end
                        fv =  rs.rh.midgray.fv;
                        src = rs.fwd.src(2);
                    end
                    x = src.rr(t.rp.hiResVert,1);
                    y = src.rr(t.rp.hiResVert,2);
                    z = src.rr(t.rp.hiResVert,3);
                    %                   plot3(x, y, z, '.', 'color', t.rp.faceColor); axis equal vis3d;
                    
                    
                    t.fv.Vertices = fv.vertex;
                    t.fv.Faces    = t.rp.fv.face;
                    t.fv.FaceColor = t.rp.faceColor;
                    t.fv.facevertexcdata = repmat(t.rp.faceColor, size(fv.vertex,1), 1);
                    h.patch.left = patch(t.fv);
                    h.light = [ light('position',[-.0512 .0128 .0128]), light('position',[.0512 .0128 .0128]) ];
                    set(gca,'dataaspectratio',[1 1 1],'view',[-90 0],'xdir','reverse')
                    set(gca, 'XTick', [], 'YTick', [], 'ZTick', []);
                    set(h.patch.left,'facecolor','interp')%,'facelighting','gouraud','edgecolor',[.1 .1 .1])
                    set(h.light,'style','local','color',[.5 .5 .5],'visible','on')
                    axis vis3d
                end
            end
            
            %           clear fv
            %           [fv.vertices,fv.faces]=mne_read_surface('/raid/MRI/anatomy/FREESURFER_SUBS/DK_fs4/surf/lh.midgray');
            %           fv.facevertexcdata = ones(size(fv.vertices,1),1);
            %           h.patch.left = patch(fv);
            %           h.light = [ light('position',[-.0512 .0128 .0128]), light('position',[.0512 .0128 .0128]) ];
            %           set(gca,'dataaspectratio',[1 1 1],'view',[-90 0],'xdir','reverse')
            %           set(gca, 'XTick', [], 'YTick', [], 'ZTick', []);
            %           set(h.patch.left,'facecolor','interp','facelighting','gouraud','edgecolor',[.1 .1 .1])
            %           lighting phong
            %           set(h.light,'style','local','color',[.5 .5 .5],'visible','on')
            %           axis vis3d
            
            %           [fv.vertices,fv.faces]=mne_read_surface('/raid/MRI/anatomy/FREESURFER_SUBS/DK_fs4/surf/rh.midgray');
            %           fv.facevertexcdata = ones(size(fv.vertices,1),1);
            %           h.patch.left = patch(fv);
            %           h.light = [ light('position',[-.0512 .0128 .0128]), light('position',[.0512 .0128 .0128]) ];
            %           set(gca,'dataaspectratio',[1 1 1],'view',[-90 0],'xdir','reverse')
            %           set(gca, 'XTick', [], 'YTick', [], 'ZTick', []);
            %           set(h.patch.left,'facecolor','interp','facelighting','gouraud','edgecolor',[.1 .1 .1])
            %           % lighting phong
            %           set(h.light,'style','local','color',[.5 .5 .5],'visible','on')
            %           axis vis3d
        end %k
        function p2(obj, rs)
            h.fig = 2000;
            figure(h.fig); clf(h.fig);
            cfg.a_patch = 'all';
            rp = rs.retinoPatch;
            for iPatch = 1:length(obj.a_patch)
                iSource = 1;
                h.timefcn.subplot(iPatch)=subplot(8,4,iPatch);
                aiPatch = rs.find_patch_source_index(obj.a_patch(iPatch), iSource);
                this.plot = rp(aiPatch).timefcn.source;
                rp(aiPatch).h.timefcn.source(1)=plot(this.plot); hold on;
                rp(aiPatch).h.timefcn.svd(1)=plot(rs.timefcn.svd.t(:,1)','r-', 'LineWidth', 1);
                title(sprintf('Patch: %g', obj.a_patch(iPatch)));
                set(gca, 'XTick', [0 25 50 75 100 120], 'XTickLabel', {'0' '50' '100' '150' '200' '240'}); grid on;
                ylim([-.11 .11])
            end
        end %k
        function plot(obj, rs)
            [junk, x, y, junk, junk, junk] = textread('./MONTREAL.lay', '%d %f %f %f %f %s');
            switch obj.dataType
                case 'meg'
                    a_chan = rs.meg_chan;
                case 'eeg'
                    a_chan = rs.eeg_chan;
                otherwise
                    error();
            end
            switch obj.type
                case 'D2-Dartboard'
                    maxV = 0;
                    minV = 0;
                    for iPatch = rs.a_patch;
                        aiPatch = iPatch;
                        irp = rs.find_patch_source_index(aiPatch, 2);
                        this.rp = rs.retinoPatch(irp);
                        maxV = max(maxV, max(this.rp.Femp.mean.norm(a_chan,:)));
                        minV = min(minV, min(this.rp.Femp.mean.norm(a_chan,:)));
                    end
                    for iPatch = rs.a_patch;
                        aiPatch = iPatch;
                        irp = rs.find_patch_source_index(aiPatch, 2);
                        this.rp = rs.retinoPatch(irp);
                        radii = [.4 .3 .2 .1]+.05;
                        theta   = (pi*5/8)-this.rp.ind*pi/4;
                        radius  = radii(ceil(this.rp.ind/8));
                        [xmod,ymod]=pol2cart(theta,radius);
                        subplot('Position', [xmod+.5 ymod+.5 .07 .07]);
                        if isequal(obj.dataType, 'eeg'),    dotSize = 20;
                        else                                dotSize = 15;
                        end
                        switch obj.ori
                            case 'x', V = this.rp.F.mean.x(a_chan,:);
                            case' y', V = this.rp.F.mean.y(a_chan,:);
                            case 'z', V = this.rp.F.mean.z(a_chan,:);
                            otherwise
                                V = this.rp.Femp.mean.norm(a_chan,:);
                        end
                        %                   C = (V-min(V))/(max(V)-min(V));
                        C = V;
                        h.scatter = scatter(x(a_chan),y(a_chan),'filled');
                        set(h.scatter, 'SizeData', dotSize, 'CData', C);
                        set(gca, 'Visible', 'off', 'CLim', [minV maxV])
                        xmax = min(x(a_chan));
                        ymax = max(y(a_chan));
                        text(xmax,ymax, sprintf('%1.0e, %1.0e',(V'*V), max(V)-min(V)));
                    end
                case 'D2-Table'
                    for iPatch = rs.a_patch;
                        subplot(4,8,iPatch);
                        aiPatch = iPatch;
                        this.rp = rs.retinoPatch(aiPatch);
                        if this.rp.area == 1
                            if isequal(obj.dataType, 'eeg'),    dotSize = 20;
                            else                                dotSize = 15;
                            end
                            switch obj.ori
                                case 'x', V = this.rp.F.mean.x(a_chan,:);
                                case' y', V = this.rp.F.mean.y(a_chan,:);
                                case 'z', V = this.rp.F.mean.z(a_chan,:);
                                otherwise
                                    V = this.rp.Femp.mean.norm(a_chan,:);
                            end
                            C = (V-min(V))/(max(V)-min(V));
                            h.scatter = scatter(x(a_chan),y(a_chan),'filled', 'CData', C);
                            set(h.scatter, 'SizeData', dotSize, 'CData', C); set(gca, 'Visible', 'off')
                        end
                    end
                case 'D2-Cortex'
                    Fmax = -1e6; Fmin = 1e6;
                    for iPatch = 1:length(rs.a_patch);
                        aiPatch = rs.a_patch(iPatch);
                        switch pp.individual
                            case true
                                for iVert = 1:length(rs(aiPatch).loResVert)
                                    Fmax = max(max(Fmax, eval(sprintf('rs.retinoPatch(aiPatch).F.individual.%s(a_chan,iVert)',rs.ori))));
                                    Fmin = min(min(Fmin, eval(sprintf('rs.retinoPatch(aiPatch).F.individual.%s(a_chan,iVert)',rs.ori))));
                                end
                            case false
                                Fmax = max(max(Fmax, eval(sprintf('rs.retinoPatch(aiPatch).F.mean.%s(a_chan)',rs.ori))));
                                Fmin = min(min(Fmin, eval(sprintf('rs.retinoPatch(aiPatch).F.mean.%s(a_chan)',rs.ori))));
                            otherwise
                        end
                    end
                    nodes = rs.nodes;
                    h.nodes = plot3(nodes(:,2), nodes(:,3), nodes(:,4), '.');
                    set(h.nodes, 'color', [ .6 .6 .6], 'HitTest', 'on', 'Tag', 'nodes');
                    hold on;
                    for iPatch = 1:length(rs.a_patch);
                        aiPatch = rs.a_patch(iPatch);
                        this.rp = rs.retinoPatch(aiPatch);
                        if isequal(obj.dataType, 'eeg'),    dotSize = 15;
                        else                                dotSize = 10;
                        end
                        switch obj.individual
                            case true
                                for iVert = 1:length(obj(aiPatch).loResVert)
                                    this.vert = obj(aiPatch).loResVert(iVert);
                                    this.offset = nodes(nodes==this.vert,2:4);
                                    switch obj.ori
                                        case 'x', V = this.obj.F.individual.x(a_chan,iVert);
                                        case 'y', V = this.obj.F.individual.y(a_chan,iVert);
                                        case 'z', V = this.obj.F.individual.z(a_chan,iVert);
                                        otherwise
                                            V = this.obj.F.individual.norm(a_chan,iVert);
                                    end
                                    ei = this.offset(1)*ones(size(a_chan,2),1)*1.1;
                                    ej = this.offset(2)  + x(a_chan)*.7e-3;
                                    ek = this.offset(3)  + y(a_chan)*.7e-3;
                                    C = (V-Fmin)/(Fmax-Fmin);
                                    if size(ei,1) < 101
                                        % Clumsy way of getting around slow
                                        % scatter 3 behavior t n < 101
                                        tmp.ei = repmat(ei(1),[101 1]);    tmp.ei(1:length(ei)) = ei;    ei = tmp.ei;
                                        tmp.ej = repmat(ej(1),[101 1]);    tmp.ej(1:length(ej)) = ej;    ej = tmp.ej;
                                        tmp.ek = repmat(ek(1),[101 1]);    tmp.ek(1:length(ek)) = ek;    ek = tmp.ek;
                                        tmp.C = repmat(C(1),[101 1]);      tmp.C(1:length(C)) = C;       C = tmp.C;
                                    end
                                    h.scatter3 = scatter3(ei,ej,ek, 'filled');
                                    set(h.scatter3, 'SizeData', dotSize, 'CData', C);
                                end
                            case false
                                this.vert = obj(aiPatch).loResVert(1);
                                this.offset = nodes(nodes==this.vert,2:4);
                                switch obj.ori
                                    case 'x', V = this.obj.F.mean.x(a_chan,:);
                                    case 'y', V = this.obj.F.mean.y(a_chan,:);
                                    case 'z', V = this.obj.F.mean.z(a_chan,:);
                                    otherwise
                                        V = this.obj.F.mean.norm(a_chan,:);
                                end
                                ei = this.offset(1)*ones(size(a_chan))*1.1;
                                ej = this.offset(2)  + x(a_chan)*1e-3;
                                ek = this.offset(3)  + y(a_chan)*1e-3;
                                C = (V-Fmin)/(Fmax-Fmin);
                                h.scatter3 = scatter3(ei,ej,ek, 'filled');
                                set(h.scatter3, 'SizeData', dotSize, 'CData', C);
                            otherwise
                        end
                    end
                    hColorbar = colorbar;
                    set(hColorbar, 'YTick', [0 1], 'YTickLabel', {sprintf('F%s=%.2g',obj.ori, Fmin) sprintf('F%s=%.2g',obj.ori, Fmax)})
                    axis equal vis3d
                otherwise
            end
        end %k
        function plot_flat2(obj)
            rs = obj.cfg.rs;
            rp = rs.retinoPatch;
            figure(171)
            for i = 1:length(rs.lh.flat.vert(:,1))
                lhverts(rs.lh.flat.vert(i,1),:) = rs.lh.flat.vert(i,2:4);
            end
            for i = 1:length(rs.rh.flat.vert(:,1))
                rhverts(rs.rh.flat.vert(i,1),:) = rs.rh.flat.vert(i,2:4);
            end
            h.lh = subplot(1,2,1); hold on; axis equal;
            patch('Faces', rs.lh.flat.tris, 'Vertices', lhverts, 'FaceColor', 'w');
            h.rh = subplot(1,2,2); hold on; axis equal;
            patch('Faces', rs.rh.flat.tris, 'Vertices', rhverts, 'FaceColor', 'w');
            for i_patch = 1:length(rp)
                this.rp = rp(i_patch);
                if isequal(this.rp.hemi,'L')
                    subplot(1,2,1)
                    this.pt = lhverts(this.rp.hiResCornerVert',:);
                    plot([this.pt(:,1); this.pt(1,1)], [this.pt(:,2); this.pt(1,2)], 'r-*',...
                        'LineWidth', 2);
                elseif isequal(this.rp.hemi, 'R')
                    subplot(1,2,2)
                    this.pt = rhverts(this.rp.hiResCornerVert',:);
                    plot([this.pt(:,1); this.pt(1,1)], [this.pt(:,2); this.pt(1,2)], 'r-*',...
                        'LineWidth', 2);
                else
                    error('Unknown hemisphere');
                end
            end
        end %k
        function plot_topo(obj, F, type)
            hptsfile = '/raid/sensors/temp/a.hpts';
            [i, i_sens, x, y, z] = textread(hptsfile, '%s %f %f %f %f'); %a.hpts
            if nargin >2
                for i = 1:length(x)
                    vect = [x(i) y(i) z(i)];
                    [vect_r(1), vect_r(2), vect_r(3)] = cart2sph(vect(1), vect(2), vect(3));
                    vect_r(3) = vect_r(3)*(max(z)-z(i))^.5;
                    [x(i) y(i) z(i)] = sph2cart(vect_r(1), 0, vect_r(3));
                end
                if isequal(type, 'flat_plus')
                    x = x + .07;
                elseif isequal(type, 'flat_minus')
                    x = x - .07;
                end
                scattersc(x(4:end),y(4:end),z(4:end),F);
                view([0 90])
            else
                scatter3sc(x(4:end),y(4:end),z(4:end),F);
            end
            axis equal
        end %k
    end
end
