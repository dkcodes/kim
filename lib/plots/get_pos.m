function gpos()
pos = get(gcf, 'position');
str = sprintf('[%g %g %g %g]', pos(1),pos(2),pos(3),pos(4));
clipboard('copy', str)
end

