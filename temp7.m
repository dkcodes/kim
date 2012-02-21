close all; 
figure(1)
plotlayout2(rp(1,1).F.mean.norm', 27); 
text(-5, -20, 'True F')
hold on; 
plotlayout2(rp(1,1).Femp.mean.norm', 27, 1);
text(25, -20, sprintf('F_{BEM}\n2mm shift'))
plotlayout2(rp(1,1).F.mean.norm', 27, 3); 
text(55, -20, 'F_{emp}')
title('Subject 1, V1, Patch 1')
xlim([-20 80]); axis equal

figure(3)
plotlayout2(rp(3,1).F.mean.norm', 27); 
text(-5, -20, 'True F')
hold on; 
plotlayout2(rp(3,1).Femp.mean.norm', 27, 1);
text(25, -20, sprintf('F_{BEM}\n2mm shift'))
plotlayout2(rp(3,1).F.mean.norm', 27, 2); 
text(55, -20, 'F_{emp}')
title('Subject 1, V3, Patch 1')
xlim([-20 80]); axis equal


