classdef retino_curveset < handle
    properties
        rs
        curve
        flatvert
    end
    
    methods
        function o = retino_curveset(rs)
            o.rs = rs;
        end
        function o = new_curve(o)
            rc = retino_curve();
            if isempty(o.curve)
                o.curve = rc;
            else
                if ~isfield_recursive(o.curve(end), 'coord', 'data', 'x')
                    if isfield_recursive(o.curve(end), 'coord', 'tmp_data', 'drawing')
                        delete(o.curve(end).coord.tmp_data.drawing);
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
        function index = get_ind(o, region, e_range, a_range)
            rs = o.rs;
            s_roi = rs.rois.name;
            e0 = e_range(1);
            e1 = e_range(2);
            a0 = a_range(1);
            a1 = a_range(2);
            fv = o.flatvert.lh;
            i_e = fv(:,4)>=e0 & fv(:,4)<=e1;
            i_a = fv(:,5)>=a0 & fv(:,5)<=a1;
            this.type = o.roi_2_binary(s_roi, region);
            i_type = (fv(:,6) == this.type);
            index = find(i_e & i_a & i_type);
        end
        function bin = add_roi_as_binary(o, fv, region)
            rs = o.rs;
            s_roi = rs.rois.name;
            bin = bitor(fv, o.roi_2_binary(s_roi, region));
        end
    end
    methods (Static)
        function bin = roi_2_binary(s_roi, region)
            bin=2^(find(cellfun( @(x) isequal(x, region), s_roi)));
        end
    end
end
