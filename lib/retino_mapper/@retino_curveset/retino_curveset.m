classdef retino_curveset < handle
    properties
        rs
        curve
        flatvert
    end
    
    methods
        function o = retino_curveset(rs)
            o.rs = rs;
            o = o.retino_curveset_gui();
        end
        function o = new_curve(o)
            rc = retino_curve(o);
            if isempty(o.curve)
                try, delete(findobj(171, 'tag', 'retino_curve')); end;
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
        function o = make_topology(o, type)
            rs = o.rs;
            
            x = [];
            y = [];
            z = [];
            for i_curve = 1:numel(o.curve)
                c = o.curve(i_curve);
                if ~isequal(c.type, type)
                    continue;
                end
                x = [x c.coord.data.x'];
                y = [y c.coord.data.y'];
                z = [z c.value*(ones(size(c.coord.data.x)))'];
            end
            st = tpaps([x;y], z, 3); % Makes spline object based on data
            
            n = o.grid.n;
            xf = rs.rh.flat.vert_full(:,2);
            yf = rs.rh.flat.vert_full(:,3);
            
            xy = [linspace(min(xf),max(xf),n); linspace(min(yf),max(yf),n)];
            [X,Y]=meshgrid(xy(1,:), xy(2,:));
            avals = fnval(st, [X(:) Y(:)]');
            colormap(jet)
            rs.h.cont = contour(X, Y, reshape(avals, n, n), 100);
        end
        function o = plot_topology(o, type)
            x = [];
            y = [];
            z = [];
            for i_curve = 1:numel(o.curve)
                c = o.curve(i_curve);
                if ~isequal(c.type, type)
                    continue;
                end
                x = [x c.data.x'];
                y = [y c.data.y'];
                z = [z c.value*(ones(size(c.data.x)))'];
            end
            plot3(x,y,z, 'k.'); axis vis3d equal; hold on;
            spos([2092         421         560         420]);
            xy0 = [x;y];
            n = 10;
            xy = [linspace(min(x),max(x),n); linspace(min(y),max(y),n)];
            st = tpaps(xy0, z, 1);
            [X,Y]=meshgrid(xy(1,:), xy(2,:));
            avals = fnval(st, [X(:) Y(:)]');
            plot3(X(:), Y(:), avals, '.')
            contour(X, Y, reshape(avals, n, n), 20)
            view([0 90])
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
        function index = get_ind(o, region_str, e_range, a_range)
            
            rs = o.rs;
            s_roi = rs.rois.name;
            e0 = e_range(1);
            e1 = e_range(2);
            a0 = a_range(1);
            a1 = a_range(2);
            fv = o.flatvert.lh;
            if isequal(e0, e1) ||  isequal(a0, a1)
                this.type = o.roi_2_binary(s_roi, region_str);
                i_type = logical(bitand(fv(:,6), this.type));
                
                [~, m]=nearpoints2d(fv(i_type,4:5)',   [e0; a0]);
                f = fv(i_type,:);
                index = f(find(m==min(m),1));
            else
                i_e = fv(:,4)>=e0 & fv(:,4)<=e1;
                i_a = fv(:,5)>=a0 & fv(:,5)<=a1;
                this.type = o.roi_2_binary(s_roi, region_str);
                i_type = bitand(fv(:,6), this.type);
                index = find(i_e & i_a & i_type);
            end
        end
        function bin = add_roi_as_binary(o, fv, region_str)
            rs = o.rs;
            s_roi = rs.rois.name;
            bin = bitor(fv, o.roi_2_binary(s_roi, region_str));
        end
        function o = retino_curveset_gui(o)
            rs = o.rs;
            s_roi = rs.rois.name;
            n_button = 15;
            pv=[repmat(.01, n_button, 1) linspace(.9,0,n_button)' repmat(.1, n_button, 1) repmat(.05, n_button, 1)];
            p.fh = 171;
            p.uh=uicontrol('unit', 'norm', 'position', [0.475 0.1 .087 .5],'style','text', ...
                'fontname','courier new','fontsize',14,'fontweight', 'bold','horizontalalignment','center');
            p.bh(1)=uicontrol('unit', 'norm', 'position', pv(1,:), 'string', 'Add', 'callback', {@o.key_fcn, o, 'a'});
            p.bh(2)=uicontrol('unit', 'norm', 'position', pv(2,:), 'string', 'Set', 'callback', {@o.key_fcn, o, 's'});
            p.bh(3)=uicontrol('unit', 'norm', 'position', pv(3,:), 'string', 'Delete', 'callback', {@o.key_fcn, o, 'd'});
            p.bh(4)=uicontrol('unit', 'norm', 'position', pv(4,:), 'string', 'Retino View', 'callback', {@o.key_fcn, o, '['});
            p.bh(5)=uicontrol('unit', 'norm', 'position', pv(5,:), 'string', 'ROI View', 'callback', {@o.key_fcn, o, ']'});
            p.bh(6)=uicontrol('unit', 'norm', 'position', pv(6,:), 'string', 'Nodes View', 'callback', {@o.key_fcn, o, '\'});
            p.roi_list=uicontrol('unit', 'norm', 'style', 'list', 'position', [pv(12,1:2) .1 .3], 'callback', {@o.key_fcn, o, '-'});
            set(p.roi_list, 'min', 1, 'max', numel(s_roi), 'string', s_roi);
            set(p.fh, 'keypressfcn', {@o.key_fcn, o});
            rs.h.curveset.gui = p;
        end
    end
    methods (Static)
        function key_fcn(~, evnt, o, id)
            h_fig = gcbf;
            p = o.rs.h.curveset.gui;
            if nargin < 4
                %     key = evnt.Key
                key = evnt.Character;
            else
                key = id;
            end
            
            release_focus(o.rs.h.main.fig);
            switch key
                case {'a'}
                    set(p.uh,'string','Add');
                    o.new_curve();
                    o.curve(end).draw_curve();
                    set(o.rs.h.curveset.gui.uh, 'backgroundcolor', rand(1,3))
                case {'s'}
                    set(p.uh,'string','Set');
                    o.curve(end).set_curve();
                    set(o.rs.h.curveset.gui.uh, 'backgroundcolor', rand(1,3))
                    figure(h_fig)
                case {'d'}
                    o.remove_curve();
                    set(o.rs.h.curveset.gui.uh, 'backgroundcolor', rand(1,3))
                    fprintf('The curveset now has %g curves.\n', numel(o.curve));
                    set(p.uh,'string', sprintf('Delete last curve.\n\n%g left.\n', numel(o.curve)));
                case {'['}
                    if  isequal(get(o.rs.h.retino.all(1), 'visible'), 'on')
                        set(o.rs.h.retino.all, 'visible', 'off')
                    else
                        set(o.rs.h.retino.all, 'visible', 'on')
                    end
                case {']'}
                    if  isequal(get(o.rs.h.rois.all.p(1), 'visible'), 'on')
                        set(o.rs.h.rois.all.p, 'visible', 'off')
                    else
                        set(o.rs.h.rois.all.p, 'visible', 'on')
                    end
                case {'\'}
                    if  isequal(get(o.rs.h.nodes.lh, 'visible'), 'on')
                        set(o.rs.h.nodes.lh, 'visible', 'off')
                        set(o.rs.h.nodes.rh, 'visible', 'off')
                    else
                        set(o.rs.h.nodes.lh, 'visible', 'on')
                        set(o.rs.h.nodes.rh, 'visible', 'on')
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
    end
end
