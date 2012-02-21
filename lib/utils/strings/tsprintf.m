function out = tsprintf(in, varargin)



if isa(in, 'char')
    count = 1;
    str = '';
    for i = 1:numel(in)
        if ~isequal(in(i), '\')
            str(count) = in(i);
            count = count + 1;
        else
            str(count:count+3) = '\\\\';
            count = count+4;
        end
    end
    in = str;
end



for i_str = 1:numel(varargin)
    var = varargin{i_str};
    if isa(var, 'char')
        count = 1;
        str = '';
        for i = 1:numel(var)
            if ~isequal(var(i), '\')
                str(count) = var(i);
                count = count + 1;
            else
                str(count:count+1) = '\\';
                count = count+2;
            end
        end
        varargin{i_str} = str;
    end
end
out = sprintf(in, varargin{:});


