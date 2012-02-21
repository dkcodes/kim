function sketch(cmd, fig)
if nargin == 0
    cmd = 'init';
end

switch cmd
    case 'init'
        set(fig, 'DoubleBuffer','on','back','off');
%         info.ax = axes('XLim',[0 1],'YLim',[0 1]);
        info.drawing = [];
        info.x = [];
        info.y = [];
        info.ax = get(gcf, 'CurrentAxes');
        set(fig,'UserData',info,...
            'WindowButtonDownFcn',[mfilename,' down']);
        
    case 'down'
        myname = mfilename;
        fig = gcbf;
        info = get(fig,'UserData');
        
        curpos = get(info.ax,'CurrentPoint');
        info.x = curpos(1,1);
        info.y = curpos(1,2);
        info.drawing = line(info.x, info.y, 'Color', 'k', 'marker', '.');
        set(fig,'UserData',info,...
            'WindowButtonMotionFcn',[myname,' move'],...
            'WindowButtonUpFcn',[myname,' up']);
        
    case 'move'
        fig = gcbf;
        info = get(fig,'UserData');
        curpos = get(info.ax,'CurrentPoint');
        info.x = [info.x;curpos(1,1)];
        info.y = [info.y;curpos(1,2)];
        set(info.drawing,'XData',info.x,'YData',info.y);
        set(fig,'UserData',info);
        
    case 'up'
        fig = gcbf;
        info = get(fig,'UserData');
        
        x_sub_ind = 1:round(numel(info.x)/100):numel(info.x);
        
        x_d = diff(info.x);
        y_d = diff(info.y);
        
        n = 5;
        
        cumsum_dist = cumsum((x_d.^2+y_d.^2).^.5);
        sum_dist = cumsum_dist(end);
        int_dist = sum_dist/n;
        

        
        for i = 1:n+1
            ind = find(abs(cumsum_dist-int_dist*(i-1))==min(abs(cumsum_dist-int_dist*(i-1))));
            x(i) = info.x(ind);
            y(i) = info.y(ind);
        end
        info.xx = x;
        info.yy = y;
        info.cumsum_dist = cumsum_dist;
        info.int_dist = int_dist;
        set(fig,'UserData',info);
        
        
        hold on;
        plot(info.xx, info.yy, 'r*');
%         for i = x_sub_ind
%             hold on;
%             plot(info.x(i), info.y(i), 'r*');
%         end
        set(fig,'WindowButtonMotionFcn','',...
            'WindowButtonUpFcn','');
        
        
end