function [ out ] = color_array( in, minimum, maximum, n )

    colors = gray(n);
    
    range = linspace(minimum, maximum, n);
    
    out = zeros(numel(in),3);
    for i = 1:numel(in)
        [~,I] = min(abs(range-in(i)));
        out(i, :) = colors(I,:);
    end

end

