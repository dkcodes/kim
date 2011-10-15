function fill_default_corner_vert(rs, cfg)
	rois = rs.rois.name;
	n_spokes    = rs.design.n_spokes;
	m           = rs.design.n_rings;
	n           = n_spokes/4;
	default_corner_vert = rs.default_corner_vert;
	default_corner_vert.patch = [];
	for i_rois = 1:numel(rois)
		fprintf('%s  ', rois{i_rois});
		this.roi_name = explode('-', rois{i_rois});
		hemi = this.roi_name{2};
		area = str2double(this.roi_name{1}(2));
		dorsal_ventral = this.roi_name{1}(3);
		if isequal(hemi, 'L')
			vert_full = rs.lh.flat.vert_full;
			if isequal(dorsal_ventral, 'D')
				offset = 0;
			else
				offset = 1*n;
			end
		elseif isequal(hemi, 'R')
			vert_full = rs.rh.flat.vert_full;
			if isequal(dorsal_ventral, 'D')
				offset = 2*n;
			else
				offset = 3*n;
			end
		else
			error('unknown hemisphere');
		end

		if isequal(cfg.type, 'patch')
			rs.thisVert.new_vert.hiResCornerVert =rs.default_corner_vert.roi(i_rois).hiResCornerVert;
		else
			for i_corner = 1:4
				rs.thisVert.button_state = 'on';
				setappdata(171,'keyChoice', 'add_new_patch')
				rs.thisVert.new_vert.i_corner = i_corner;
				figure(171);
				uiwait(171);
				fprintf('%s:%g - ', rois{i_rois}, i_corner);
			end
		end

		p1 = rs.thisVert.new_vert.hiResCornerVert(1);
		p2 = rs.thisVert.new_vert.hiResCornerVert(2);
		p3 = rs.thisVert.new_vert.hiResCornerVert(3);
		p4 = rs.thisVert.new_vert.hiResCornerVert(4);

		default_corner_vert.roi(i_rois).name = rois{i_rois};
		default_corner_vert.roi(i_rois).hiResCornerVert = rs.thisVert.new_vert.hiResCornerVert;

		for i_u = 1:n
			for i_v = 1:m
				lat_ind(i_v, i_u) = i_u + (i_v-1)*n_spokes;
			end
		end
		lat_ind = lat_ind + offset;
		if mod(area,2)==0
			lat_ind = fliplr(lat_ind);
		end

		pos1 = vert_full(p1,2:end);
		pos2 = vert_full(p2,2:end);
		pos3 = vert_full(p3,2:end);
		pos4 = vert_full(p4,2:end);

		try delete(h.previous_roi); end
		roi_x = [pos1(1) pos2(1) pos3(1) pos4(1) pos1(1)];
		roi_y = [pos1(2) pos2(2) pos3(2) pos4(2) pos1(2)];
		h.previous_roi = plot(roi_x, roi_y, 'ro-', 'LineWidth', 1.5', 'MarkerSize', 10, 'MarkerFaceColor', 'b');
		u12 = pos2-pos1;
		u43 = pos3-pos4;

		for i_u = 0:n
			lat{1, i_u+1} = pos1 + u12*i_u/n;
		end

		for i_u = 0:n
			lat{m+1, i_u+1} = pos4 + u43*i_u/n;
		end

		for i_u = 0:n
			for i_v = 1:m-1
				lat{i_v+1, i_u+1} = lat{1, i_u+1} + (lat{m+1, i_u+1}-lat{1, i_u+1})*i_v/m;
			end
		end
		for i_u = 0:n
			for i_v = 0:m
				this.pos = lat{i_v+1, i_u+1};
				[a,b]=nearpoints(vert_full(:,2:4)', this.pos');
				b(b==0) = inf;
				[a, b]=min(b);
				hiResCornerVert(i_v+1, i_u+1) = b;
			end
		end
		for i_u = 1:n
			for i_v = 1:m
				t.hiResCornerVert(1) = hiResCornerVert(i_v, i_u);
				t.hiResCornerVert(2) = hiResCornerVert(i_v, i_u+1);
				t.hiResCornerVert(3) = hiResCornerVert(i_v+1, i_u+1);
				t.hiResCornerVert(4) = hiResCornerVert(i_v+1, i_u);
				default_corner_vert.patch(area,lat_ind(i_v, i_u)).name = rois{i_rois};
				default_corner_vert.patch(area,lat_ind(i_v, i_u)).hiResCornerVert = t.hiResCornerVert;
				default_corner_vert.patch(area,lat_ind(i_v, i_u)).hemi            = hemi;
			end
		end
	end
	rs.default_corner_vert = default_corner_vert;
	save(fullfile(rs.dirs.berkeley, 'default_corner_vert.mat'), 'default_corner_vert');
	try delete(h.previous_roi); end
	fprintf('\n');
end
