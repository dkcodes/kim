classdef retino_curve < handle
    properties
        region % Visual regions 'V3V-L'
        type   % (e)ccentricity or (a)ngle
        val    % value of e or a
        coord  % coordinates 
    end
    methods
        function o = retino_curve()
        end
        function o = draw_curve(o)
            o.sketch([],[], 'init', 171, o)
        end
        function o = set_curve(o)
            if ~isfield_recursive(o.coord, 'tmp_data')
                disp('Does not seem like o.coord has any data. Draw the curve and set the data')
                return
            else
                o.coord.data = o.coord.tmp_data;
                if isempty(o.type)
                    o.type = input('(e)ccentricities / (a)ngle? : ', 's');
                end
                if isempty(o.val)
                    o.val = input('Enter the value for ecc/angle : ');
                end
                fprintf('Curve set to   :   (%s, %g)\n', o.type, o.val')
            end
        end
    end
    methods (Static)
        function sketch(~, ~, cmd, fig, o)
            if nargin == 0
                cmd = 'init';
            end
            switch cmd
                case 'init'
                    set(fig, 'DoubleBuffer','on','back','off');
                    h.axes = findobj(fig, 'type', 'axes');
                    info.drawing = [];
                    info.x = [];
                    info.y = [];
                    
                    set(fig,'UserData',info,...
                        'WindowButtonDownFcn', {@retino_curve.sketch, 'down', fig, o });
                case 'down'
                    fig = gcbf;
                    info = get(fig,'UserData');
                    info.ax = get(gcf, 'CurrentAxes');
                    try, delete(info.drawing), end
                    curpos = get(info.ax,'CurrentPoint');
                    info.x = curpos(1,1);
                    info.y = curpos(1,2);
                    
                    info.drawing = line(info.x, info.y, 'Color', 'k', 'marker', '.', 'tag', 'retino_curve');
                    set(fig,'UserData',info,...
                        'WindowButtonMotionFcn',{@retino_curve.sketch, 'move', fig, o },...
                        'WindowButtonUpFcn',{@retino_curve.sketch, 'up', fig, o });
                case 'move'
                    fig = gcbf;
                    info = get(fig,'UserData');
                    curpos = get(info.ax,'CurrentPoint');
                    info.x = [info.x; curpos(1,1)];
                    info.y = [info.y; curpos(1,2)];
                    set(info.drawing,'XData',info.x,'YData',info.y);
                    set(fig,'UserData',info);
                case 'up'
                    fig = gcbf;
                    info = get(fig,'UserData');
                    set(fig,'UserData',info);
                    o.coord.tmp_data = info;
                    set(fig,'WindowButtonMotionFcn','', ...
                            'WindowButtonUpFcn','');
            end
        end
    end
end