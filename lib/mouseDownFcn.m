function mouseDownFcn(hFig, empt)
	keyChoice   = getappdata(hFig, 'keyChoice');
	rs          = getappdata(hFig, 'rs');
	rp          = rs.retinoPatch;
	fwd         = rs.fwd;

	hAx = findobj(hFig,'type','axes');
	target = get_target(hFig, rs);
	if length(hAx) > 1
		figtarget    = get(hFig, 'CurrentPoint');
		figPosition  = get(hFig,'Position');
		if figtarget(1)<(figPosition(3)/2)
			rs.thisVert.hemi = 'L';
			nodesAll    = rs.lh.flat.vert_full;
			h.nodes = rs.h.nodes.lh; % this needs to be non-specific
		else
			rs.thisVert.hemi = 'R';
			nodesAll    = rs.rh.flat.vert_full;
			h.nodes = rs.h.nodes.rh; % this needs to be  non-specific
		end
	end
	if ~isempty(keyChoice)
		switch keyChoice
			case 'd'
				h.corner = [];
				for iPatch = 1:size(rp,2)*size(rp,1)
					if  isfield(rp(iPatch).h, 'corner')
						h.corner = [h.corner rp(iPatch).h.corner];
					end
				end
				[empt,V,empt,empt] = vertexpicker(h.corner, target);
				rs.thisVert.sourceVert = find(ismember(nodesAll(:,2:4),V,'rows'));
				rs.thisVert.aPatch = [];
				for iPatch = 1:size(rp,2)*size(rp,1)
					if  ~isempty(find(rp(iPatch).hiResCornerVert==rs.thisVert.sourceVert,1))
						[tmp.a, tmp.y] = find(rp(iPatch).hiResCornerVert==rs.thisVert.sourceVert);
						rs.thisVert.modifyInd{iPatch} =[tmp.a tmp.y];
						rs.thisVert.aPatch = [rs.thisVert.aPatch iPatch];
					end
				end

				fprintf('d')
			case 'f'
				[empt,V,empt,empt] = vertexpicker(h.nodes, target);
				rs.thisVert.destVert = find(ismember(nodesAll(:,2:4),V,'rows'));
				if ~isempty(rs.thisVert.aPatch)
					for iPatch = rs.thisVert.aPatch
						rp(iPatch).hiResCornerVert(rp(iPatch).hiResCornerVert==rs.thisVert.sourceVert) = rs.thisVert.destVert;
						rp(iPatch).fill_surf_from_corner();
						rp(iPatch).calculate_forward_hi();
						rp(iPatch).update_fig('corner');
						rp(iPatch).update_fig('surf');
					end
					rs.thisVert.aPatch = [];
				end
				%             setappdata(hFig, 'rp', rp);
				fprintf('f')
			case 'a'
				new_vert =  [];
				setappdata(hFig,'keyChoice', []);
				for i_corner = 1:4
					disp('Click next point');
					new_corner_type = input('Existing (1) or non-existing (2) corner : ');
					target = get_target(hFig, rs);
					if new_corner_type == 1
						destVert = get_corner(rp, target, nodesAll);
						this.h(i_corner) = plot3(nodesAll(destVert,2), nodesAll(destVert,3), nodesAll(destVert,4), 'rs');
					else
						[empt,V,empt,empt] = vertexpicker(h.nodes, target);
						destVert = find(ismember(nodesAll(:,2:4),V,'rows'));
						this.h(i_corner) = plot3(nodesAll(destVert,2), nodesAll(destVert,3), nodesAll(destVert,4), 'rs');
					end
					new_vert(i_corner) = destVert;
					figure(171);
				end
				pause(.75);
				%          try;  delete(this.h); end;
				fprintf('Adding a new patch \n')
				setappdata(0,'new_vert', new_vert);
			case 'p'
				fprintf('p')
			case '/'
				setappdata(hFig,'keyChoice', []);
			case 'add_new_patch'
				uiresume(171);
				[empt,V,empt,empt] = vertexpicker(h.nodes, target);
				i_corner = rs.thisVert.new_vert.i_corner;
				v = find(ismember(nodesAll(:,2:4),V,'rows'));
				rs.thisVert.new_vert.hiResCornerVert(i_corner) = v;
				this.h.p = plot(nodesAll(v,2), nodesAll(v,3), 'ro');
				pause(.2);
				delete(this.h.p);
				rs.thisVert.button_state = 'on';
			otherwise
		end
	end
end

function sourceVert = get_corner(rp, target, nodesAll)
	h.corner = [];
	for iPatch = 1:size(rp,2)*size(rp,1)
		if  isfield(rp(iPatch).h, 'corner')
			h.corner = [h.corner rp(iPatch).h.corner];
		end
	end
	[empt,V,empt,empt] = vertexpicker(h.corner, target);
	sourceVert = find(ismember(nodesAll(:,2:4),V,'rows'));
end

function target = get_target(hFig, rs)
	hAx = findobj(hFig,'type','axes');
	target = get(hAx, 'CurrentPoint');
	if length(hAx) > 1
		figtarget    = get(hFig, 'CurrentPoint');
		figPosition  = get(hFig,'Position');
		if figtarget(1)<(figPosition(3)/2)
			target = target{2};
		else
			target = target{1};
		end
	end
end
