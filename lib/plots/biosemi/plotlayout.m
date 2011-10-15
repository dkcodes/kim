function p = plotlayout(p)
	% p.V = p.V = linspace(0,1,128);
	% p.filename = 'biosemi128.ced';
	xy=flatten_ced(p);
	p.h.s=scatter(xy(:,1), xy(:,2)); axis equal
	c1 = p.V-min(p.V); c1 = c1/max(c1);
	set(p.h.s, 'LineWidth', 10, 'CData', repmat(c1(:), [1 3]));   axis equal vis3d

function out=flatten_ced(p)
	fid = fopen(p.filename);   fgetl(fid); C=textscan(fid,'%d %s %f %f %f %f %f %f %f %f');    fclose(fid);
	a=C{5}; b=C{6}; c=C{7};
	[theta, phi, R] = cart2sph(a,b,c);
	R = 5-phi;
	ind = (phi<1.3); R(ind) = (5-phi(ind));
	ind = (phi<1.15); R(ind) = (5-phi(ind));
	ind = (phi<.5); R(ind) = (5.25-phi(ind));
	ind = (phi<.25); R(ind) = (5.5-phi(ind));
	ind = (phi<0); R(ind) = (6-phi(ind));
	ind = (phi<-.2); R(ind) = 6.75-phi(ind);
	ind = (phi<-.4); R(ind) = 8-phi(ind);
	[x,y,z]=sph2cart(theta,phi,R);
	out = [x y];


