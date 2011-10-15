function obj = fill_default_corner_vert(obj)
	obj.hiResCornerVert = obj.session.default_corner_vert.patch(obj.area, obj.ind).hiResCornerVert;
end %k
