close all;
figure(1);
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
t_svd{i_sub}= t(:,1:3);
format compact
tt = corrcoef(t(:,1), V{1}); 
corr_VC(1) = tt(1,2);
tt = corrcoef(t(:,2), V{2}); 
corr_VC(2) = tt(1,2);
tt = corrcoef(t(:,3), V{3}); 
corr_VC(3) = tt(1,2);
corr_VC


tt = corrcoef(rs.ctf(1,:), V{1}); 
corr_VCTF(1) = tt(1,2);
tt = corrcoef(rs.ctf(2,:), V{2}); 
corr_VCTF(2) = tt(1,2);
try
tt = corrcoef(rs.ctf(3,:), V{3}); 
corr_VCTF(3) = tt(1,2);
end
corr_VCTF


subplot(3,2,1);
plot([V{1}' V{2}' V{3}']);
title('True Source');
legend('1', '2', '3');

subplot(3,2,3);
plot(rs.ctf');
title('Est. Source');

subplot(3,2,5);
plot(t(:,1:3));
title('SVD');

subplot(3,2, [2 4 6]);
vars = diag(s.^2)/sum(diag(s.^2));
stem(vars(1:5), '*');
text(1.5, 0.4, sprintf('%0.2g      ', corr_VC))
title('SVD');


return
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
return
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
