function release_focus(fig)
set(findobj(fig, 'Type', 'uicontrol'), 'Enable', 'off');
drawnow;
set(findobj(fig, 'Type', 'uicontrol'), 'Enable', 'on');