close all;
temp.data = rs.data.mean;
n_patch = size(temp.data,1);
n_sens  = size(temp.data,2);
n_kern  = size(temp.data,3);
n_time  = size(temp.data,4);

data = [];
for i_patch = 1:numel(rs.a_patch)
		ai_patch = rs.a_patch(i_patch);
		t.rp = rp(1, ai_patch);
    for i_kern = 1:size(temp.data,3)
        data = [data; rs.concat_V_kern(t.rp)];
    end
end
[u,s,t] = svd(data);
clc
t_svd{i_subj}= t(:,1:3);
format compact
for i_source = rs.a_source
  tt = corrcoef(t(:,i_source), V{i_source}); 
  corr_VSVD(i_source) = tt(1,2);
end
corr_VSVD

for i_source = rs.a_source
  tt = corrcoef(rs.ctf(i_source,:), V{i_source}); 
  corr_VCTF(i_source) = tt(1,2);
end
corr_VCTF

h_svd = randi(1e6);
figure(h_svd);
subplot(3,2,1);
if isequal(numel(rs.a_source),3)
  plot([V{1}' V{2}' V{3}']);
  legend('1', '2', '3');
else
  plot([V{1}' V{2}']);
  legend('1', '2');
end
title('True Source');

subplot(3,2,3);
plot(rs.ctf');
title('Est. Source');

subplot(3,2,5);
plot(t(:,1:3));
title('SVD');

subplot(3,2, [2 4 6]);
vars = diag(s.^2)/sum(diag(s.^2));
stem(vars(1:5), '*');
text(1.5, 0.4, sprintf('%0.2g      ', corr_VSVD))
title('SVD');

str_svd = sprintf('svd_%s', subj_id);
filename_fig_svd = fullfile('.', 'out', 'fig',  g.dirs, str_svd);
saveas(h_svd, filename_fig_svd);
continue








%%
figure(2);
clc
rs.a_patch = 1:8;
n_patch = numel(rs.a_patch);
n_source = numel(rs.a_source);
for i_patch = 1:n_patch
  for i_source = 1:n_source
    subplot(n_patch, n_source, i_source + (i_patch-1)*n_source);
    F1 = u([1:128]+(i_patch-1)*128, i_source); F1 = F1/norm(F1);
    F2 = rp(i_source, i_patch).F.mean.norm;    F2 = F2/norm(F2);
    F_corr = corrcoef(F1, F2); sign_corr = sign(F_corr(1,2)) ;
    F2 = F2*sign_corr;
    rplot.plot_topo(F1, 'flat_minus'); hold on;
    %         rplot.plot_topo(F1); hold on;
    title(sprintf('Patch %g, Source %g', i_patch, i_source)); 
    rplot.plot_topo(F2, 'flat_plus');
    %         rplot.plot_topo(F2);
    title(sprintf('Patch %g, Source %g', i_patch, i_source)); 

    F_diff(i_patch, i_source) = sum((F1-F2).^2);
  end
end
figure(3); plot(F_diff);
title('SSE(F_{real}, F_{svd})');
legend('1', '2', '3');
continue
%%
clc
i_source = 1;
for i_patch = 1:8;
  for i_source = 1:3
    [u,v,t] = svd(squeeze(rs.data.mean(i_patch, :, 1, :)));

    F1 = u([1:128], i_source);
    F2 = rp(i_source, i_patch).F.mean.norm;
    F_corr = corrcoef(F1, F2), sign_corr = sign(F_corr(1,2));

    figure(1);
    subplot(1,2,1);
    rplot.plot_topo(F1);
    title(sprintf('Patch %g, Source %g', i_patch, i_source)); 
    subplot(1,2,2);
    rplot.plot_topo(sign_corr*F2);
    title(sprintf('Patch %g, Source %g', i_patch, i_source)); 
  end
end
