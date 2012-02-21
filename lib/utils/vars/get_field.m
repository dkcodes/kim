function get_field(cfg)
    fields = fieldnames(cfg);
    for i_vars = 1:numel(fields)
        assignin('caller', fields{i_vars}, cfg.(fields{i_vars}));
    end
