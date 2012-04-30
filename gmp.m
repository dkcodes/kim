function p=gmp(o)
pv=[
    10*ones(10,1) linspace(100,500,10)' repmat(70, 10, 1) repmat(20, 10, 1)
    ];
p.fh=171;
p.uh=uicontrol('position', [0 0 1 1],'style','text','fontname','courier new','fontsize',10,'horizontalalignment','left');
p.bh(1)=uicontrol('position', pv(1,:), 'string', 'Add', 'callback', {@key_fcn, o, 'a'});
p.bh(2)=uicontrol('position', pv(2,:), 'string', 'Set', 'callback', {@key_fcn, o, 's'});
p.bh(3)=uicontrol('position', pv(3,:), 'string', 'Delete', 'callback', {@key_fcn, o, 'd'});
p.bh(4)=uicontrol('position', pv(4,:), 'string', 'View Retino', 'callback', {@key_fcn, o, '['});
p.bh(5)=uicontrol('position', pv(5,:), 'string', 'View ROI', 'callback', {@key_fcn, o, ']'});
p.bh(6)=uicontrol('position', pv(6,:), 'string', 'View Nodes', 'callback', {@key_fcn, o, '\'});

set(p.fh, 'keypressfcn', {@key_fcn, o});

return;
%-----------------------------------------
function key_fcn(h_fig, evnt, o, id)
if nargin < 4
    %     key = evnt.Key
    key = evnt.Character;
else
    key = id;
end
switch key
    case {'a'}
        disp('Adding a new curve');
        o.new_curve();
        o.curve(end).draw_curve();
    case {'s'}
        disp('Setting the curve');
        o.curve(end).set_curve();
        figure(h_fig)
    case {'d'}
        disp('Delete last curve');
        o.remove_curve();
        fprintf('The curveset now has %g curves.\n', numel(o.curve));
    case {'h'}
        disp('Switch Hemisphere');
        o.remove_curve();
        fprintf('The curveset now has %g curves.\n', numel(o.curve));
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
        if  isequal(get(o.rs.h.rois.all.p(1), 'visible'), 'on')
            set(o.rs.h.rois.all.p, 'visible', 'off')
        else
            set(o.rs.h.rois.all.p, 'visible', 'on')
        end
    otherwise
end
return;