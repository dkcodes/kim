cfg_workspace.var_to_clear = rs;
fn = fieldnames(cfg_workspace.var_to_clear);
for i = 1:numel(fn)
  if ~isequal(fn, 'rp') 
    eval(sprintf('clear %s;', fn{i}, fn{i}))
  end
end
clear fn cfg_workspace i
