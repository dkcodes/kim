function h = patchplot(xi, yi1, yi2)
x = [xi(:); flipud(xi(:))];
y = [yi1(:); flipud(yi2(:))];
c = [1 1 1]* .8;
patch(x,y,c)


