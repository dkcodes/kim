function plotlay(V, layfile)

	if nargin<2
		layfile = sprintf('raid/MRI/toolbox/fieldtrip/fieldtrip-read-only/template/biosemi%g.lay', n);
	end
	% [i, x, y, a, b, s] = textread(layfile, '%d %f %f %f %f %s');
	[i, i_sens, x, y, z] = textread(layfile, '%s %f %f %f %f'); %a.hpts
	for i = 1:length(x)
		vect = [x(i) y(i) z(i)];
		[vect_r(1), vect_r(2), vect_r(3)] = cart2sph(vect(1), vect(2), vect(3));
		vect_r(3) = vect_r(3)*(max(z)-z(i))^.5;
		[x(i) y(i) z(i)] = sph2cart(vect_r(1), 0, vect_r(3));
	end
	C = (V-min(V));
	C = C/max(V);
	C = V;
	h.scatter = scatter(x(4:end),y(4:end),'filled');
	% h.scatter = scatter3(x(4:end),y(4:end),z(4:end),'filled');
	set(h.scatter, 'SizeData', 50, 'CData', C);
	%caxis([-10 10]);
	axis equal
