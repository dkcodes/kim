clear
clc
close all;

h.b1 =uicontrol('position', [20 220 60 20])
h.b2 =uicontrol('position', [20 120  60 20])
h.b3 =uicontrol('position', [20 20  60 20])

n = 2
for i = 1 : n
  controlName = [ 'b' num2str(i) ];
  set(h.(controlName), 'visible', 'off')
end
shg
