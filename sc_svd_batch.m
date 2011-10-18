clear
s_subj={                    
'skeri0001'             
'skeri0004'            
'skeri0009'            
'skeri0017'            
'skeri0035'            
'skeri0037'            
%% 'skeri0039'          
'skeri0044'           
'skeri0048'           
'skeri0050'           
'skeri0051'           
'skeri0053'           
'skeri0054'           
'skeri0060'           
'skeri0066'           
'skeri0069'           
'skeri0071'           
'skeri0072'           
'skeri0075'           
'skeri0076'           
'skeri0078'           
'skeri0081'           
};
g.dirs = 'temp';
g.desc = sprintf('Comparing with Hood. Do svd as before, but only use 3 electrodes + a reference electrode at the inion. In Hood, the electrodes are placed in sagital (4cm +z) and transverse (4cm =-x) directions. For us, Standford data only has 128 channel electrodes which are 3 and 5 cm apart. We will pick the 5 cm apart electrodes, which should be more lenient for the SVD. The electrode #s at (inion: 81), (-x: 68), (+x: 94), (+z: 75).\n a_chan = [68 75 81 94] \n reference set to (inion: 81)');
g.list = s_subj;


toggle_make_params = 0;
if toggle_make_params
% Modify make_params.m to reflect experimental parameters.
  make_params(g);
end

info = load_params(fullfile('in', 'param', g.dirs, 'info.mat'));
for i_subj = 1:numel(s_subj)
  this.filename = fullfile ('in', 'param', info.g.dirs, info.g.list{i_subj});
  p = load_params(this.filename);
  run('sc_analyze_src');
  run('sc_svd');
end
this.dirs_out = fullfile('out', info.g.dirs, 'mat', 'stat.mat');
save(this.dirs_out, 'stat');
continue;


























svd_stat_all = reshape([svd_stat.corr_VC],3, numel([svd_stat.corr_VC])/3)';
tt_svd = t_svd;
figure(1010); clf(1010);
for i=1:numel(t_svd)
    signs = sign(svd_stat(i).corr_VC);
    tt_svd{i}(:,1) = t_svd{i}(:,1)*signs(1);
    tt_svd{i}(:,2) = t_svd{i}(:,2)*signs(2);
    tt_svd{i}(:,3) = t_svd{i}(:,3)*signs(3);
    plot(tt_svd{i}(:,1), 'b'); hold on;
    plot(tt_svd{i}(:,2)+1, 'g');
    plot(tt_svd{i}(:,3)+2, 'r');
end
plot(V{1}*.5+0, 'k', 'LineWidth', 5)
plot(V{2}*.5+1, 'k', 'LineWidth', 5)
plot(V{3}*.15+2, 'k', 'LineWidth', 5)

%dp = dot_prod_1;
%c_pair = {[1 1], [2 2], [3 3], [1 2], [1 3], [2 3]}; 
%for i=1:6, 
	%for j=1:numel(s_subj), 
		%c1 = c_pair{i}(1); 
	%	c2 = c_pair{i}(2); 
	%	cp(j,i) = dp(j,i)/sqrt(dp(j,c1)*dp(j,c2)); 
%	end;
%end;



svd_stat_all1= reshape([svd_stat.corr_VC],3, numel([svd_stat.corr_VC])/3)';
svd_stat_all2 = reshape([svd_stat.corr_VCTF],2, numel([svd_stat.corr_VC])/3)';
%%
noise_level = 0;
n_source_acc = 2;
title_str = sprintf('%gX%g : noise= %g : source_{acc}= %g', n_spokes, n_rings, noise_level, n_source_acc);
filename_str = sprintf('./pic/%gX%g_noise=%g_source_{acc}=%g_ratio322_jitter_norm_down_1-60-120elec', n_spokes, n_rings, noise_level, n_source_acc);

figure(1011); clf(1011);
subplot(1,2,1)
plot(abs(svd_stat_all1))
title('corr(SVD, V_{true})')
xlabel('subject id'), ylabel('corr')
ylim([-1 1])
text(1,-.7, title_str);
subplot(1,2,2)
plot(abs(svd_stat_all2))
title('corr(SVD, V_{true})')
xlabel('subject id'), ylabel('corr')
ylim([-1 1])
saveas(1011, filename_str, 'png')

eval_str = sprintf('scp -r "%s.png" c:/raid/pic/', filename_str);
system(eval_str)

%%
%try, clf(120), end; figure(120); 
% bar(roi_area(:,1), 'FaceColor', [0 0 1]); hold on;
% bar(roi_area(:,2), 'FaceColor', [.2 .6 .3]);
% bar(roi_area(:,3), 'FaceColor', [.9 .2 0]);
% stem(roi_area, 'o', 'MarkerSize', 8, 'MarkerFaceColor', 'auto');
% xlim([-3 25]);
