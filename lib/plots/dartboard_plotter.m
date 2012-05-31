classdef dartboard_plotter < handle
    properties
        pat
        a_patch
    end
    methods
        function obj = dartboard_plotter(a_patch)
            obj.pat.text = 'off';
            obj.a_patch = a_patch;
        end
        function obj = make_dartboard(obj, n_ring, n_spoke, dartboard_color)
            a_patch = obj.a_patch;
            r = 100;
            angles = linspace(2*pi+pi/2, 0+pi/2,  n_spoke+1);
            angles(n_spoke+1) = [];
            eccentricities = linspace(r, 60, n_ring+1);
            
            figure(randi(1203813))
            count = 1;
            for rho = eccentricities
                for theta = angles
                    [x(count,1), y(count,1)] = pol2cart(theta, rho);
                    count = count + 1;
                end
            end
            axis square equal
            set(gca, 'visible', 'off')
            for i = 1:n_ring*n_spoke
                if isempty(intersect(i, n_spoke:n_spoke:n_spoke*n_ring))
                    corners = [i i+1 i+n_spoke+1 i+n_spoke];
                else
                    corners = [i i-n_spoke+1 i+1 i+n_spoke];
                end
                pat(i).corners = corners;
                pat(i).x = x(corners);
                pat(i).y = y(corners);
                pat(i).mean_x = mean(pat(i).x);
                pat(i).mean_y = mean(pat(i).y);
                fv = [];
                fv.vertices = [x y];
                fv.faces = corners;
                pat(i).fv = fv;
            end
            count = 1;
            c = color_scale(dartboard_color);
            for i_patch = 1:numel(a_patch)
                ai_patch = a_patch(i_patch);
                hold on;
                if nargin<4
                    if mod(count,2)==0
                        % This is used to background color the patches
                        colors = [0 0 0];
                        %                     colors = [1 1 1];
                    else
                        colors = [1 1 1];
                    end
                else
                    
                    colors = c(i_patch,:);
                end
                
                
                if isempty(intersect(ai_patch, n_spoke:n_spoke:n_spoke*n_ring))
                    count = count + 1;
                end
                fv = pat(ai_patch).fv;
                patch('Faces', fv.faces, 'Vertices', fv.vertices, 'FaceColor', colors )
                mean_x = mean(pat(ai_patch).x);
                mean_y = mean(pat(ai_patch).y);
                
                %                 text(mean_x, mean_y, num2str(ai_patch), 'color', xor([1 1 1], colors), ...
                %                     'horizontalalignment', 'center', 'fontsize', 15, 'fontweight', 'bold')
            end
            x_lim = get(gca, 'XLim');
            y_lim = get(gca, 'YLim');
            
            x_max = x_lim(2); x_min = x_lim(1);
            y_max = y_lim(2); y_min = y_lim(1);
            
            axis_position = get(gca, 'position');
            axis_x = axis_position(1);
            axis_y = axis_position(2);
            axis_width = axis_position(3);
            axis_height = axis_position(4);
            
            x_transform = [axis_width/x_max axis_x];
            y_transform = [axis_height/y_max axis_y];
            
            for i_patch = 1:numel(a_patch)
                ai_patch = a_patch(i_patch);
                pat(ai_patch).axis_x = x_transform * [(pat(ai_patch).mean_x - x_min)*.5; 1];
                pat(ai_patch).axis_y = y_transform * [(pat(ai_patch).mean_y - y_min)*.5; 1];
            end
            % geometry.
            set(gcf, 'color', 'white')
            set(gcf, 'position', [2362         379         560         420])
            
            hold on;
            for i_patch = 1:numel(a_patch)
                ai_patch = a_patch(i_patch);
                pat(ai_patch).h_axis = axes;
                axis_x = pat(ai_patch).axis_x;
                axis_y = pat(ai_patch).axis_y;
                axis_width = .075;
                axis_height = .05;
                
                set(pat(ai_patch).h_axis, ...
                    'position', [axis_x-(axis_width/2) axis_y-(axis_height/2)  axis_width axis_height], ...
                    'XTick', [], 'YTick', [], 'color', 'none');
%                 box on
            end
            obj.pat = pat;
        end
        function obj = update_plot(obj)
            a_patch = obj.a_patch;
            for i_patch = 1:numel(a_patch)
                ai_patch = a_patch(i_patch);
                tt_pat = obj.pat(ai_patch);
                h_axis = tt_pat.h_axis;
                if ~isempty(tt_pat.type) && ~isempty(h_axis)
                    axes(h_axis);
                    switch tt_pat.type
                        case 'topography_dartboard'
                            colors = jet(1000);
                            for i_comp = 1:1
                                u_set1 = tt_pat.data.topo.weight;
                                variance_set1 = tt_pat.data.topo.variance;
                                min_set1 = min(u_set1(:, 1:3));
                                max_set1 = max(u_set1(:, 1:3));
                                plotlayout2(u_set1, 128, 0); hold on;
                                [junk, I]=min(abs(linspace(min(variance_set1(i_comp,:)), max(variance_set1(i_comp)), 1000) - variance_set1(i_comp)));
                                plot(-17, 17, 'o', 'markerfacecolor', colors(I,:), 'markeredgecolor', 'none')
                                %                                 u = u_set2(i_patch, :, i_comp);
                                %                                 plotlayout2(u', n_chan, 1, [min(u) max(u)])
                                %                                 [junk, I]=min(abs(linspace(min(variance_set2(i_comp,:)), max(variance_set2(i_comp,:)), 1000) - variance_set2(i_comp, i_patch)));
                                %                                 plot(57, 17, 'o', 'markerfacecolor', colors(I,:), 'markeredgecolor', 'none')
                                text(0, 25, num2str(ai_patch))
                                set(gca, 'box', 'off', 'XTickLabel', '', 'yticklabel', '', 'color', 'none', 'xcolor', 'w', 'ycolor', 'w')
                                set(gca, 'visible', 'off')
                                xlim([-40 40])
                                ylim([-20 20])
                            end
                        otherwise
                            
                            if isfield(tt_pat, 'data') &&  isfield(tt_pat.data, 'y') && ~isempty(tt_pat.h_axis)
                                h_axis = tt_pat.h_axis;
                                axes(h_axis);
                                if isfield(tt_pat.data, 'x') && isequal(size(tt_pat.data.x, 1), size(tt_pat.data.y))
                                    plot(tt_pat.data.x, tt_pat.data.y, 'linewidth', 2);
                                    set(h_axis, 'XTick', [], 'YTick', [], 'color', 'none');
                                else
                                    plot(tt_pat.data.y, 'linewidth', 2);
                                    set(h_axis, 'XTick', [], 'YTick', [], 'color', 'none', 'xcolor', 'w', 'ycolor', 'w');
                                    ylim([-0.0045 0.0045])
                                    xlim([-20 length(tt_pat.data.y)+20])
                                    set(gca, 'XColor', 'w')
                                    box off
                                end
                            end
                    end
                end
            end
        end
    end
end