function [h, a_color] = scatter2sc(x,y,s1,min_max)
h=scatter(x, y, '.');
colorm = jet(1000);
if nargin <=3
  c1 = s1-min(s1); c1 = c1/max(c1);
  c1 = c1*.5;
  c1 = c1+.25;
  l = linspace(0,1, 1000);
  for i = 1:size(c1,1)
    a=c1(i);
    i_color=find(abs(l-a)==min(abs(l-a)));
    colors(i,:) = colorm(i_color,:);
    a_color(i) = i_color;
  end
elseif nargin == 4
  c_min = min_max(1);
  c_max = min_max(2);
  ref   = linspace(c_min, c_max, 1000);
  for i = 1:numel(s1)
    if s1(i) < c_min
      i_color = 1;
    elseif s1(i) > c_max
      i_color = 1000;
    else
      i_color=find(abs(ref-s1(i))==min(abs(ref-s1(i))));
    end
  colors(i,:) = colorm(min(i_color),:);
  a_color(i) = min(i_color);
  end
end

set(h, 'LineWidth',  1, 'CData', colors); axis equal vis3d;
