function obj = calculate_forward_hi(obj)
    a_vert = obj.hiResVert;
    rs = obj.session;
    a_chan = rs.a_chan;
    fwd = obj.session.fwd;






    switch obj.hemi
        case 'L'
            src = fwd.src(1);
            nn = src.nn(a_vert,:).*repmat(src.source_weight(a_vert,:),[1 3]);
            aa = (rs.a(a_vert)-1)*3;
            rr = src.rr(a_vert,:);
        case 'R'
            src = fwd.src(2);
            nn = src.nn(a_vert,:).*repmat(src.source_weight(a_vert,:),[1 3]);
            aa = (fwd.src(1).nuse + int32(rs.b(a_vert)-1))*3;
            rr = src.rr(a_vert,:);
        otherwise
            error();
        end








        Fx=fwd.sol.data(a_chan,1+aa);
        Fy=fwd.sol.data(a_chan,2+aa);
        Fz=fwd.sol.data(a_chan,3+aa);

        %  temporary: Referencing to Hood's electrode 81. (3rd electrode in a_chan)
        Fx = Fx - repmat(Fx(75,:), size(Fx, 1), 1 );
        Fy = Fy - repmat(Fy(75,:), size(Fy, 1), 1 );
        Fz = Fz - repmat(Fz(75,:), size(Fz, 1), 1 );
        %
        % Average referencing
        % Fx = Fx - repmat(mean(Fx), size(Fx, 1), 1 );
        % Fy = Fy - repmat(mean(Fy), size(Fy, 1), 1 );
        % Fz = Fz - repmat(mean(Fz), size(Fz, 1), 1 );

        obj.F.mean.norm(a_chan,:)  = [Fx Fy Fz]*nn(:);
        %obj.F.mean.norm  = [Fx Fy Fz]*nn(:);
        obj.F.weight = src.source_weight(a_vert,:);
        obj.hi_res_norm.data = nn;
        obj.hi_res_norm.sum = sum(nn);
        obj.hi_res_norm.pos = rr;


        obj.F.mean.x_w = Fx * obj.F.weight;
        obj.F.mean.y_w = Fy * obj.F.weight;
        obj.F.mean.z_w = Fz * obj.F.weight;
%        obj.F.mean.x = mean(Fx, 2);
%        obj.F.mean.y = mean(Fy, 2);
%        obj.F.mean.z = mean(Fz, 2);


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
