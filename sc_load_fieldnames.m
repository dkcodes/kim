fn = fieldnames(p);
for i_fn = 1:numel(fn)
  eval(sprintf('%s = p.%s;', fn{i_fn}, fn{i_fn}))
end
clear fn i_fn
