close all;

stat(i_subj).subj_id = subj_id;

temp.data = rs.data.mean;
n_patch = size(temp.data,1);
n_sens  = size(temp.data,2);
n_kern  = size(temp.data,3);
n_time  = size(temp.data,4);

data = [];
for i_patch = 1:numel(rs.a_patch)
  ai_patch = rs.a_patch(i_patch);
  this.rp = rp(1, ai_patch);
  for i_kern = 1:size(temp.data,3)
    data = [data; rs.concat_V_kern(this.rp)];
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
stat(i_subj).svd.T_all.corr = corr_VSVD;
corr_VSVD

for i_source = rs.a_source
  tt = corrcoef(rs.ctf(i_source,:), V{i_source}); 
  corr_VCTF(i_source) = tt(1,2);
end
stat(i_subj).true.T_all.corr = corr_VCTF;
corr_VCTF

% Calculate the angles between the F's of different sources.
% The independence of time functions betwen V1/V2/V3 will
% most likely be determined by the orthogonality of V1/V2/V3
% topographies (i.e. rp(1,i).F Vs rp(2,i).F vs rp(3,i).F

F_all =[];
UF_all = [];
for i_patch = 1:numel(rs.a_patch)
  ai_patch = rs.a_patch(i_patch);
  F = []; UF = [];
  for i_source = rs.a_source
    F(:,i_source) = rp(i_source, ai_patch).F.mean.norm;
    UF(:,i_source) = u(:,i_source);
  end
  F_all = [F_all; F];
  UF_all = [UF_all; UF];

  for i_source = rs.a_source
    stat(i_subj).true.F(i_patch).sum(i_source) = ...
      F(:, i_source)' * F(:, i_source);
    stat(i_subj).svd.F(i_patch).sum(i_source) = ...
      UF(:, i_source)' * UF(:, i_source);
    for j_source = rs.a_source
      stat(i_subj).true.F(i_patch).angles(i_source, j_source) = ...
        subspace( F(:, i_source), F(:, j_source) );
      stat(i_subj).svd.F(i_patch).angles(i_source, j_source) = ...
        subspace( UF(:, i_source), UF(:, j_source) );
    end
  end
end
for i_source = rs.a_source
  stat(i_subj).true.F_all.sum = ...
    F_all(:, i_source)' * F_all(:, i_source);
  stat(i_subj).svd.F_all.sum = ...
    UF_all(:, i_source)' * UF_all(:, i_source) ;
  for j_source = rs.a_source
    stat(i_subj).true.F_all.angles(i_source, j_source) = ...
      subspace( F_all(:, i_source), F_all(:, j_source) );
    stat(i_subj).svd.F_all.angles(i_source, j_source) = ...
      subspace( UF_all(:, i_source), UF_all(:, j_source) );
  end
end



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
stem(vars(1:3), '*');
text(1.5, 0.4, sprintf('%0.2g      ', corr_VSVD))
title('SVD');

str_svd = sprintf('svd_%s', subj_id);
filename_fig_svd = fullfile('.', 'out', g.dirs, 'fig',   str_svd);
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
