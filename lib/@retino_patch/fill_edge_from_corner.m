function obj = fill_edge_from_corner(obj, nodes, segments)
	obj.hiResEdgeVert = [];
	nCorner = length(obj.hiResCornerVert);
	for iCorner = 1:nCorner
		sourceVert = obj.hiResCornerVert(mod(iCorner-1,nCorner)+1);
		destVert = obj.hiResCornerVert(mod(iCorner,nCorner)+1);
		r1 = nodes(nodes(:,1)==sourceVert,2:4);
		r2 = nodes(nodes(:,1)==destVert,2:4);
		thresh = (r1-r2)*(r1-r2)'*(.53)^2;
		midpoint = (r1+r2)*.5;
		d=dist(nodes(:,2:4), midpoint');
		this.nodes = nodes(d<thresh,:);
		[junk, edgeVert] = dijkstra(this.nodes, segments, sourceVert, destVert);
		obj.hiResEdgeVert = [obj.hiResEdgeVert; edgeVert'];
	end
end %k
