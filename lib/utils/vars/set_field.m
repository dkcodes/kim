function cfg = set_cfg(varargin)
    for i_vars = 1:nargin
        if isstr(varargin{i_vars})
            cfg.(sprintf('%s', varargin{i_vars})) = evalin('caller', sprintf('%s', varargin{i_vars}));
        else
            error('variable name must be string class');
        end
    end
