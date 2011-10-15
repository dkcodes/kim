fn = fieldnames(params);
for i = 1:numel(fn)
  eval(sprintf('%s = params.%s;', fn{i}, fn{i}))
end
clear fn params i
