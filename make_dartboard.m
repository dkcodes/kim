function pat = make_dartboard(n_rings, n_spokes)
    r = 100;
    angles = linspace(2*pi+pi/2, 0+pi/2,  n_spokes+1);
    angles(n_spokes+1) = [];
    eccentricities = linspace(r, 10, n_rings+1);

    figure(randi(1203813))
    count = 1;
    for rho = eccentricities
        for theta = angles
            [x(count,1), y(count,1)] = pol2cart(theta, rho);
            count = count + 1;
        end
    end
%    plot(x, y, '.', 'linewidth', 10)
    axis square equal
    set(gca, 'visible', 'off')

    count = 1;
    for i = 1:n_rings*n_spokes
        if isempty(intersect(i, n_spokes:n_spokes:n_spokes*n_rings))
            corners = [i i+1 i+n_spokes+1 i+n_spokes];
        else
            corners = [i i-n_spokes+1 i+1 i+n_spokes];
        end
        pat(i).corners = corners;
        pat(i).x = x(corners);
        pat(i).y = y(corners);
        fv = [];
        fv.vertices = [x y];
        fv.faces = corners;
        pat(i).fv = fv;
    end
    count = 1;
    for i_pat = 1:32
        hold on;
        if mod(count,2)==0
            colors = [0 0 0]
        else
            colors = [1 1 1]
        end
        if isempty(intersect(i_pat, n_spokes:n_spokes:n_spokes*n_rings))
            count = count + 1;
        end
        fv = pat(i_pat).fv;
        patch('Faces', fv.faces, 'Vertices', fv.vertices, 'FaceColor', colors )
        mean_x = mean(pat(i_pat).x);
        mean_y = mean(pat(i_pat).y);
        text(mean_x, mean_y, num2str(i_pat), 'color', xor([1 1 1], colors), ...
            'horizontalalignment', 'center', 'fontsize', 15, 'fontweight', 'bold')
    end


