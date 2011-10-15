function obj = fill_surf_from_edge(obj, nodesAll, nodes)
	obj.hiResVert = [];
	edgePos = nodesAll(obj.hiResEdgeVert,2:4);
	normalvec0 = [1 -1 0];
	options = [];    options.Display = 'off'; options.LargeScale='off';
	obj.normalvec = fminunc(@(x)AreaCost(x,edgePos),normalvec0,options); % I want a normal vector that maximizes the area of the patch
	uvPos = edgePos*null(obj.normalvec);


	xmin = min(edgePos(:,1))-abs(min(edgePos(:,1))*.1);
	xmax = max(edgePos(:,1))+abs(max(edgePos(:,1))*.1);
	ymin = min(edgePos(:,2))-abs(min(edgePos(:,2))*.1);
	ymax = max(edgePos(:,2))+abs(max(edgePos(:,2))*.1);
	zmin = min(edgePos(:,3))-abs(min(edgePos(:,3))*.1);
	zmax = max(edgePos(:,3))+abs(max(edgePos(:,3))*.1);

	windowed.nodes = nodes(  (nodes(:,2)<=xmax & nodes(:,2) >= xmin) & (nodes(:,3)<=ymax & nodes(:,3) >= ymin) & (nodes(:,4)<=zmax & nodes(:,4) >= zmin),:);
	%          windowed.nodes = nodes(  (nodes(:,2)<=max(nodes(:,2)) & nodes(:,2) >= min(nodes(:,2))) & (nodes(:,3)<=max(nodes(:,3)) & nodes(:,3) >= min(nodes(:,3))) & (nodes(:,4)<=max(nodes(:,4)) & nodes(:,4) >= min(nodes(:,4))),:);
	uvNearByNodes = windowed.nodes(:,2:end)*null(obj.normalvec);
	L = inpolygon(uvNearByNodes(:,1), uvNearByNodes(:,2), uvPos(:,1), uvPos(:,2));
	obj.hiResVert = windowed.nodes(L,1);
end %k
