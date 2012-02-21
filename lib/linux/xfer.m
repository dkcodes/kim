function xfer(filename)
  if isequal(nargin, 1)
    cmd = sprintf('rsync -avzh %s cyclops.berkeley.edu:~/out/', filename);
    system(cmd);
  end
