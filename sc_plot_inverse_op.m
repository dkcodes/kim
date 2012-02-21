clear F W f
for i_patch = 1:size(rp,2)
    F{i_patch} = [rp(1, i_patch).F.mean.norm rp(2, i_patch).F.mean.norm rp(3, i_patch).F.mean.norm];
    f = F{i_patch};
    W{i_patch} = (f'*f)\f';
    pi{i_patch} = pinv(f'*f);
end


%%
close all
i_subplot = 0;
for i_patch = 13:24
    i_subplot = i_subplot + 1;
    subplot(2,12,i_subplot)
    plotlayout2(F{i_patch}(:,1)', 27); hold on;
    plotlayout2(F{i_patch}(:,2)', 27, 1)
    %     plotlayout2(F{3, i_patch}', 27)
end
i_subplot = 12;
for i_patch = 13:24
    i_subplot = i_subplot + 1;
    subplot(2,12,i_subplot)
    plotlayout2(W{i_patch}(1,:), 27); hold on;
    plotlayout2(W{i_patch}(2,:), 27, 1)
    %     plotlayout2(F{3, i_patch}', 27)
end
set(gcf, 'paperpositionmode', 'auto')
sgcf([1926 587 1904 296])