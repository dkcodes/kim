classdef retino_curveset < handle
    properties
        rs
        curve
        flatvert
        ring
        spoke
    end
    properties (SetObservable=true)
        current
    end
    
    methods
        function o = retino_curveset(rs)
            o.rs = rs;
            o = o.gui();
            try,
                disp('Trying to load curveset data if it exists');
                o.load();
            end
            addlistener(o, 'current', 'PostSet', @o.handle_prop_events);
            o.current = 1;
        end
        function o = new_curve(o)
            rc = retino_curve(o);
            if isempty(o.curve)
                try, delete(findobj(o.rs.h.main.fig, 'tag', 'retino_curve')); end;
                o.curve = rc;
            else
                if ~isfield_recursive(o.curve(end), 'coord', 'data', 'x')
                    if isfield_recursive(o.curve(end), 'coord', 'tmp_data', 'drawing')
                        try, delete(o.curve(end).coord.tmp_data.drawing); end;
                    end
                    disp('Does not seem like o.curve(end).coord.data.x is set')
                    disp('Simply redraw the curve, and set the curve');
                    return;
                else
                    if isempty(o.curve(end).coord.data.x)
                        o.curve(end) = rc;
                    else
                        o.curve(end+1) = rc;
                    end
                end
            end
        end
        function o = remove_curve(o, ind)
            if nargin<2
                if isempty(o.curve)
                    disp('This curveset contains no curves.')
                    return
                else
                    try
                        delete(o.curve(end).coord.data.drawing)
                    end
                    o.curve(end) = [];
                end
            else
                if ind > numel(o.curve)
                    fprintf('This curveset only has %g curves.\n', numel(o.curve))
                    return
                else
                    try
                        delete(o.curve(end).coord.data.drawing)
                    end
                    o.curve(ind) = [];
                end
            end
            
        end
        function o = plot_curve(o)
            try, delete(findobj(o.rs.h.curveset.gui.fh, 'tag', 'retino_curve')); end;
            for i_curve = 1:numel(o.curve)
                this_curve = o.curve(i_curve);
                x = this_curve.coord.data.x;
                y = this_curve.coord.data.y;
                o.curve(i_curve).h.ax = o.rs.h.main.(this_curve.hemi);
                subplot(o.rs.h.main.(this_curve.hemi))
                o.curve(i_curve).h.line = plot(x, y, 'k.-', 'tag', 'retino_curve');
            end
        end
        function index = get_ind(o, region_str, e_range, a_range, opt)
            rs = o.rs;
            s_roi = rs.rois.name;
            e0 = e_range(1);
            e1 = e_range(2);
            a0 = a_range(1);
            a1 = a_range(2);
            hemi = region_str(end);
            if isequal(hemi, 'L') || isequal(hemi, 'lh')
                fv = o.flatvert.lh;
            elseif isequal(hemi, 'R') || isequal(hemi, 'rh')
                fv = o.flatvert.rh;
            end
            if isequal(e0, e1) ||  isequal(a0, a1)
                this.type = o.roi_2_binary(s_roi, region_str);
                i_type = logical(bitand(fv(:,6), this.type));
                [~, m]=nearpoints2d(fv(i_type,4:5)',   [e0; a0]);
                f = fv(i_type,:);
                index = f(find(m==min(m),1));
            else
                margin = 5e-2;
                i_e = fv(:,4)>=e0 & fv(:,4)<=e1;
                i_a = fv(:,5)>=a0+margin & fv(:,5)<=a1-margin;
                this.type = o.roi_2_binary(s_roi, region_str);
                i_type = bitand(fv(:,6), this.type);
                index = find(i_e & i_a & i_type);
            end
            if nargin>4 && isequal(opt, 'rm_outlier')
                outlier_index = o.find_outlier(fv(index,2), fv(index,3));
                index(outlier_index) = [];
            end
        end
        function bin = add_roi_as_binary(o, fv, region_str)
            rs = o.rs;
            s_roi = rs.rois.name;
            bin = bitor(fv, o.roi_2_binary(s_roi, region_str));
        end
        function o = gui(o)
            rs = o.rs;
            s_roi = rs.rois.name;
            n_button = 25;
            pv=[repmat(.01, n_button, 1) linspace(.9,0,n_button)' repmat(.1, n_button, 1) repmat(.8/n_button, n_button, 1)];
            p.fh = o.rs.h.main.fig;
            p.uh=uicontrol('unit', 'norm', 'position', [0.475 0.1 .087 .5],'style','text', ...
                'fontname','courier new','fontsize',14,'fontweight', 'bold','horizontalalignment','center');
            p.bh(1)=uicontrol('unit', 'norm', 'position', pv(1,:), 'string', 'a  Add', 'callback', {@o.key_fcn, o, 'a'});
            p.bh(2)=uicontrol('unit', 'norm', 'position', pv(2,:), 'string', 's  Set', 'callback', {@o.key_fcn, o, 's'});
            p.bh(3)=uicontrol('unit', 'norm', 'position', pv(3,:), 'string', 'd  Delete', 'callback', {@o.key_fcn, o, 'd'});
            p.bh(4)=uicontrol('unit', 'norm', 'position', pv(4,:), 'string', '1  Toggle Retino', 'callback', {@o.key_fcn, o, '1'});
            p.bh(5)=uicontrol('unit', 'norm', 'position', pv(5,:), 'string', '2  Toggle ROI', 'callback', {@o.key_fcn, o, '2'});
            p.bh(6)=uicontrol('unit', 'norm', 'position', pv(6,:), 'string', '3  Toggle Nodes', 'callback', {@o.key_fcn, o, '3'});
            p.bh(7)=uicontrol('unit', 'norm', 'position', pv(7,:), 'string', '4  Toggle Curve', 'callback', {@o.key_fcn, o, '4'});
            
            eh_pn = {'unit', 'style', 'callback',           'backgroundcolor'};
            eh_pv = {'norm', 'edit',  {@o.key_fcn, o, '/'}, 'w'};
            p.eh(1)=uicontrol(eh_pn, eh_pv); set(p.eh(1),'position', [pv(8,1:2)  .07 pv(8,4)] );
            p.bh(8)=uicontrol('unit', 'norm', 'position', [pv(8,1)+.075 pv(8,2)  .025 pv(8,4)], 'string', 'Set', 'callback', {@o.key_fcn, o, 'set_region'});
            p.eh(2)=uicontrol(eh_pn, eh_pv); set(p.eh(2),'position', [pv(9,1:2)  .07 pv(9,4)] );
            p.eh(3)=uicontrol(eh_pn, eh_pv); set(p.eh(3),'position', [pv(10,1:2) .07 pv(10,4)] );
            
            p.slider =uicontrol('unit', 'norm', 'style', 'slider', 'sliderstep', [1 1], 'min', 1, 'max', 2, 'value', 1, ...
                'position', [.3, pv(1,2) .4 pv(1,4)], 'callback', {@o.key_fcn, o, '|'});
            
            p.roi_list=uicontrol('unit', 'norm', 'style', 'list', 'position', [pv(n_button-1,1:2) .1 .3], 'callback', {@o.key_fcn, o, '-'});
            set(p.roi_list, 'min', 1, 'max', numel(s_roi), 'string', s_roi);
            set(p.fh, 'keypressfcn', {@o.key_fcn, o});
            rs.h.curveset.gui = p;            
        end
        function o = save(o)
            save_path = o.rs.dirs.berkeley;
            var = {'region', 'type', 'val', 'coord', 'h', 'hemi'};
            for i_curve = 1:numel(o.curve)
                for i_var = 1:numel(var)
                    curve(i_curve).(var{i_var}) = o.curve(i_curve).(var{i_var});
                end
            end
            save(fullfile(save_path, 'curveset_data.mat'), 'curve');
        end
        function o = load(o)
            load_path = o.rs.dirs.berkeley;
            load(fullfile(load_path, 'curveset_data.mat'), 'curve');
            var = {'region', 'type', 'val', 'coord', 'h', 'hemi'};
            o.curve = retino_curve(o);
            for i_curve = 1:numel(curve)
                o.curve(i_curve) = retino_curve(o);
                for i_var = 1:numel(var)
                    o.curve(i_curve).(var{i_var}) = curve(i_curve).(var{i_var});
                end
                o.curve(i_curve).curveset = o;
            end
            try
                delete(findobj(o.rs.h.curveset.gui.fh, 'tag', 'retino_curve'));
            end;
            o.key_fcn([], [], o, 'curve_on');
            o.key_fcn([], [], o, 'slider');
        end
        
    end
    methods (Static)
        function key_fcn(~, evnt, o, id)
            h_gui = o.rs.h.curveset.gui;
            h_fig = h_gui.fh;
            s_roi = o.rs.rois.name;
            if nargin < 4
                %     key = evnt.Key
                key = evnt.Character;
            else
                key = id;
            end
            
            release_focus(o.rs.h.main.fig);
            switch key
                case {'a'}
                    set(h_gui.uh,'string','Add'); 
                    set(o.rs.h.curveset.gui.uh, 'backgroundcolor', rand(1,3));
                    o.new_curve();
                    o.curve(end).draw_curve();
                case {'s'}
                    set(h_gui.uh,'string', 'Set'); 
                    set(o.rs.h.curveset.gui.uh, 'backgroundcolor', rand(1,3));
                    o.curve(end).set_curve();
                    o.key_fcn([], [], o, 'slider');
                    figure(h_fig); % Brings the focus back from command prompt to figure
                case {'d'}
                    set(h_gui.uh,'string', sprintf('Delete.\n\n%g left.\n', numel(o.curve)));
                    set(o.rs.h.curveset.gui.uh, 'backgroundcolor', rand(1,3));
                    o.remove_curve(o.current);
                    o.key_fcn([], [], o, 'slider');
                    o.plot_curve();
                    fprintf('The curveset now has %g curves.\n', numel(o.curve));
                case {'1'}
                    tog_vis(o.rs.h.retino.all)
                case {'2'}
                    tog_vis(o.rs.h.rois.all.p)
                case {'3'}
                    tog_vis(o.rs.h.nodes.lh)
                    tog_vis(o.rs.h.nodes.rh)
                case {'4' 'curve_on' 'curve_off'} % Toggling curve visibility
                    h_retino_curve = findobj(gcf, 'tag', 'retino_curve');
                    if isempty(h_retino_curve)
                        o.plot_curve();
                    end
                    if isequal(key, 'curve_off'),
                        vis_toggle = false;
                    elseif isequal(key, 'curve_on')
                        vis_toggle = true;
                    elseif isequal(get(h_retino_curve(1), 'visible'), 'off')
                        vis_toggle = true;
                    else
                        vis_toggle = false;
                    end
                    tog_vis(h_retino_curve)
                case {'|' 'slider'} % Changing slider
                    n_curve = numel(o.curve);
                    if n_curve < 1
                        return;
                    elseif n_curve ==  1
                        set(h_gui.slider, 'min', 1, 'max', n_curve+1, 'sliderstep', [1 1]) 
                    else
                        set(h_gui.slider, 'min', 1, 'max', n_curve, 'sliderstep', [1 1]/(n_curve-1)) 
                    end
                    i_curve   = round(get(h_gui.slider, 'value'));
                    o.current = i_curve; % Triggers handle_prop_events
                case {'/' 'set_region'} % Changing the field
                    n_curve = numel(o.curve);
                    i_curve   = get(h_gui.slider, 'value');
                    if i_curve <= n_curve
                        region = get(h_gui.eh(1), 'string');
                        type   = get(h_gui.eh(2), 'string');
                        val    = get(h_gui.eh(3), 'string');
                        o.curve(i_curve).type = type;
                        o.curve(i_curve).val = str2num(val);
                        if isempty(region) || isequal(key, 'set_region')
                            i_region = get(o.rs.h.curveset.gui.roi_list,'value');
                            o.curve(i_curve).region = o.roi_2_binary(s_roi, {s_roi{i_region}});
                            set(h_gui.eh(1), 'string', num2str(o.curve(i_curve).region));
                        else
                            o.curve(i_curve).region = str2num(region);
                        end
                    end
                case {'-'}
                otherwise
            end
        end
        function bin = roi_2_binary(s_roi, region)
            bin = 0;
            if ~iscell(region)
                region = {region};
            end
            for i_region = 1:numel(region)
                this.region = region{i_region};
                if isequal(sum(cellfun( @(x) isequal(x, this.region), s_roi)), 0)
                    error(sprintf('%s does not exist in the roi list', this.region));
                else
                    bin = bin + 2^(find(cellfun( @(x) isequal(x, this.region), s_roi)));
                end
            end
        end
        function handle_prop_events(src,evnt)
            o = evnt.AffectedObject;
            this_curve = o.curve(o.current);
            h_gui = o.rs.h.curveset.gui;
            switch src.Name % switch on the property name
                case 'current'
                    set(h_gui.eh(1), 'string', num2str(this_curve.region));
                    set(h_gui.eh(2), 'string', this_curve.type);
                    set(h_gui.eh(3), 'string', num2str(this_curve.val));
                    try
                        for i_curve = 1:numel(o.curve)
                            if i_curve==o.current
                                set(o.curve(i_curve).h.line, 'color', 'r');
                            else
                                set(o.curve(i_curve).h.line, 'color', 'k');
                            end
                        end
                    end
                otherwise
            end
        end
        function out = linspace_ecc(in_1, in_2, n_ring)
            small = min(in_1, in_2);
            large = max(in_1, in_2);
            div = (large-small)/n_ring;
            ecc_1 = (small:div:large-div)';
            ecc_2 = (small+div:div:large)';
            out = flipud([ecc_1 ecc_2]);
        end
        function out = linspace_ang(in_1, in_2, n_spoke)
            small = min(in_1, in_2);
            large = max(in_1, in_2);
            div = (large-small)/n_spoke;
            ang_1 = (small:div:large-div)';
            ang_2 = (small+div:div:large)';
            out = [ang_1 ang_2];
        end
        function out = find_outlier(x, y)
            mean_x = mean(x);
            mean_y = mean(y);
            mean_std_x = mean(std(x));
            mean_std_y = mean(std(y));
           out = find(sum([x-mean_x y-mean_y].^2,2)> 10*(mean_std_x^2+mean_std_y^2));
            
        end
    end
end
