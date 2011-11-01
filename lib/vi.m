function vi(str)
  system(sprintf('gvim --remote-tab %s &', str))
