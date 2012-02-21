function out = norm2(mat, opt)
  out = sqrt( sum( mat .^ 2, opt) );
