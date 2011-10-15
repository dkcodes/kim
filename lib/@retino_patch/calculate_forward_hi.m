function obj = calculate_forward_hi(obj)
	a_vert = obj.hiResVert;
	rs = obj.session;
	chan = rs.chan;
	fwd = obj.session.fwd;
	switch obj.hemi
		case 'L'
			src = fwd.src(1);
			nn = src.nn(a_vert,:).*repmat(src.source_weight(a_vert,:),[1 3]);
			aa = (rs.a(a_vert)-1)*3;
		case 'R'
			src = fwd.src(2);
			nn = src.nn(a_vert,:).*repmat(src.source_weight(a_vert,:),[1 3]);
			aa = (fwd.src(1).nuse + int32(rs.b(a_vert)-1))*3;
		otherwise
			error();
	end
	Fx=fwd.sol.data(chan,1+aa);
	Fy=fwd.sol.data(chan,2+aa);
	Fz=fwd.sol.data(chan,3+aa);
	obj.F.mean.norm(chan,:)  = [Fx Fy Fz]*nn(:);
	%obj.F.mean.norm  = [Fx Fy Fz]*nn(:);
	obj.F.weight = src.source_weight(a_vert,:);
	obj.hi_res_norm.data = nn;
	obj.hi_res_norm.sum = sum(nn);
	%%      
	%%%  This part is used to plot the surfaces of the sources
	%        colors = jet(10);
	%        if obj.area == 1 && obj.ind==8
	%           %           irand = randi(10000);
	%           %           figure(irand);clf(irand);
	%           figure(120123)
	%           switch obj.hemi
	%              case 'L'
	%                 %                rr = fwd.src(1).rr;
	%                 %                tris = fwd.src(1).tris;
	%                 %                patch('Faces',tris,'Vertices',rr,'facecolor','w')
	%                 %                hold on;
	%                 rr = fwd.src(1).rr(a_vert,:);
	%                 plot3(rr(:,1), rr(:,2), rr(:,3), '.', 'color', colors(randi(10),:));
	%                 hold on;
	%                 nn = fwd.src(1).nn(a_vert,:);
	% %                 quiver3(rr(:,1), rr(:,2), rr(:,3), nn(:,1), nn(:,2), nn(:,3),'.');
	%                 
	%                 rr= fwd.source_rr(rs.a(a_vert),:);
	%                 x = rr(:,1); y = rr(:,2); z = rr(:,3);
	%                 plot3(x,y,z,'r*', 'LineWidth', 5); axis vis3d equal
	%              case 'R'
	%                 %                rr = fwd.src(1).rr;
	%                 %                tris = fwd.src(1).tris;
	%                 %                patch('Faces',tris,'Vertices',rr,'facecolor','w')
	%                 %                hold on;
	%                 rr = fwd.src(2).rr(a_vert,:);
	%                 plot3(rr(:,1), rr(:,2), rr(:,3), '.', 'color', colors(randi(10),:));
	%                 hold on;
	%                 nn = fwd.src(2).nn(a_vert,:);
	% %                 quiver3(rr(:,1), rr(:,2), rr(:,3), nn(:,1), nn(:,2), nn(:,3),'.');
	%                 
	%                 rr= fwd.source_rr(int32(rs.b(a_vert))+fwd.src(1).nuse,:);
	%                 x = rr(:,1); y = rr(:,2); z = rr(:,3);
	%                 plot3(x,y,z,'r*', 'LineWidth', 5); axis vis3d equal
	%           end
	%           title([num2str(obj.ind) '  ' num2str(obj.area)])
	%           
	% %           set(gca, 'XLim', [0.0001    0.0067])
	% %           set(gca, 'YLim', [-0.0689   -0.0622])
	% %           set(gca, 'ZLim', [0.0055    0.0198])
	%           view([-68 48])
	%        end
end %k
