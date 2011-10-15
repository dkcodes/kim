function [h, a_color] = scattersc(x,y,z,s1)
	c1 = s1-min(s1); c1 = c1/max(c1);

	c1 = c1*.5;
	c1 = c1+.25;

	h=scatter3(x, y, z, 'o');
	colorm = jet(1000);
	l = linspace(0,1,1000);
	for i = 1:size(c1,1)
		a=c1(i);
		i_color=find(abs(l-a)==min(abs(l-a)));
		colors(i,:) = colorm(i_color,:);
		a_color(i) = i_color;
	end
	set(h, 'LineWidth',  3, 'CData', colors); axis equal vis3d;
