%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
i_patch = 24;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



s1 = rs.fwd.src(1);
s2 = rs.fwd.src(2);
nn1 = s1.nn(s1.vertno, :);
nn2 = s2.nn(s2.vertno, :);
nna = [nn1; nn2];
sol = rs.fwd.sol.data;
n_ori = 1;


for i_n = 1:size(nna, 1)
    nn = nna(i_n, :)';
    source = sol(:, (i_n-1)*3 + (1:3));
    sol_1(:, i_n) = source*nn;
end
if n_ori == 1
  sol = sol_1;
end

x = rs.fwd.source_rr(:,1); 
y = rs.fwd.source_rr(:,2); 
z = rs.fwd.source_rr(:,3);

%%
% i_patch = 93;
% 
% F1 = rp(1, i_patch).F.mean.norm;
% F2 = rp(2, i_patch).F.mean.norm;
% F3 = rp(3, i_patch).F.mean.norm;

% LF = [sol F1 F2 F3]; 
% LF = [sol(272:327,:)];
LF = [sol(1:128,:)]; 
lf = n_ori; 
data_pre = 1e-8; 

data_post = squeeze(rs.data.mean(i_patch, :, 1, :));
% data_post = squeeze(b(1, :, :));

[gamma, s_bar, w] = bare_bones_champagne(data_pre, data_post, LF, lf, x, y, z);

%%
figure(10000); clf(10000); sgcf([1 357 1024 657])
% h.sp(1) = subplot(2,3,1);

w2 = sum(w.^2,2);
n_ind_max = numel(find(w2>=.1*max(w2)));
colors = jet(n_ind_max);
[~, ind_max] = sort(w2, 'descend');
i_x = 1:10:numel(x); 
subplot(n_ind_max, 3, setdiff(1:n_ind_max*3, 3:3:n_ind_max*3)); hold on;
title(sprintf('Patch #%g', i_patch))
plot3(x(i_x), y(i_x), z(i_x), '.', 'color', [.5 .5 .5]);
for i_champ_pos = 1:n_ind_max
  try
  h.champ_pos(i_champ_pos) = plot3(x(ind_max(i_champ_pos)), y(ind_max(i_champ_pos)), z(ind_max(i_champ_pos)),...
    'o', 'markerfacecolor', colors(i_champ_pos, :));
  end
end
try; set(h.champ_pos, 'markersize', 10); end
for i_text = 1:20
  try
  text(x(ind_max(i_text)), y(ind_max(i_text)), z(ind_max(i_text)), num2str((i_text)), 'fontsize', 10);
  end
end

rp(1, i_patch).fill_sources_from_surf();
rp(2, i_patch).fill_sources_from_surf();
rp(3, i_patch).fill_sources_from_surf();

try; delete(h.sc); end;
clear source*
for i_source = 1:3
  trp = rp(i_source, i_patch);
  offset = double(rs.fwd.src(1).nuse); % If the patch is on left visual field
%   offset = double(0);
  source_x{i_source} = rs.fwd.source_rr(trp.sourceInd+offset, 1)';
  source_y{i_source} = rs.fwd.source_rr(trp.sourceInd+offset, 2)';
  source_z{i_source} = rs.fwd.source_rr(trp.sourceInd+offset, 3)';
  hold on;
  h.sc(i_source) = plot3(source_x{i_source}, source_y{i_source}, source_z{i_source}, ...
    'p', 'color', colors(i_source,:), 'markerfacecolor', colors(i_source, :), 'markeredgecolor', 'k');
  set(h.sc(i_source), 'markersize', 10);
end


axis vis3d equal;
view([0 0])
drawnow

champ_t = s_bar(ind_max(1:n_ind_max),:);
true_t = [rs.sim.true.timefcn{1}; rs.sim.true.timefcn{2}; rs.sim.true.timefcn{3}];
norm_true_t = norm(norm(true_t(1,:)));
for i_ind_max = 1:n_ind_max
    scales(i_ind_max,:) = norm(champ_t(i_ind_max,:))/norm_true_t;
end
for i_ind_max = 1:n_ind_max
    subplot(n_ind_max, 3, 3*i_ind_max); hold on;
    plot(champ_t(i_ind_max,:)/scales(i_ind_max), 'linewidth', 4, 'color', colors(i_ind_max,:))
    legend('')
    for i_source = 1:n_source
        plot(true_t(i_source,:), 'linewidth', 2, 'color', colors(i_source,:))
    end
end

return
%%
h.sp(2) = subplot(2,3,2); cla;
copyobj(allchild(h.sp(1)), h.sp(2)); view([0 90]); axis vis3d equal;
h.sp(3) = subplot(2,3,3); cla;
copyobj(allchild(h.sp(1)), h.sp(3)); view([90 0]); axis vis3d equal;
h.sp(4) = subplot(2,3,4); cla; 
copyobj(allchild(h.sp(1)), h.sp(4)); view([0 0]);  xlim([-.005 0.02]); zlim([0.055 0.07])
h.sp(5) = subplot(2,3,5); cla;
copyobj(allchild(h.sp(1)), h.sp(5)); view([0 90]); axis vis3d equal; ylim([-.12 -.1]); xlim([-.005 0.02])
h.sp(6) = subplot(2,3,6); cla;
copyobj(allchild(h.sp(1)), h.sp(6)); view([90 0]); axis vis3d equal; ylim([-.12 -.1]); zlim([0.055 0.07])
return
%%
[~, ind_max] = sort(sum(w.^2, 2) , 'descend');
t_true = reshape([rs.sim.true.timefcn{:}], 100, 3);
V_champ = w'*s_bar;
rr = zeros(size(s_bar, 1), 3);
for i_vert = 1:size(s_bar, 1)
  t = s_bar(i_vert,:);
  r_temp = corrcoef([t' t_true]);
  rr(i_vert, :) = r_temp(1, 2:end);
end
max(rr)
s = [];
s(1) = find(max(rr(:,1)) == rr(:,1));
s(2) = find(max(rr(:,2)) == rr(:,2));
s(3) = find(max(rr(:,3)) == rr(:,3));

try; delete(h.sc_champ_src); end
for is = 1:numel(s)
  xx(is) = x(s(is));
  yy(is) = y(s(is));
  zz(is) = z(s(is));
  h.sc_champ_src(is) = plot3(xx(is), yy(is), zz(is), 'o', 'markerfacecolor', colors(is, :));
end
try; set(h.sc_champ_src, 'markersize', 10); end;


figure(10001);
subplot(5,1,1); plot(t_true);    title('True Sources,  Total Source # = 3')
subplot(5,1,2); plot(rs.ctf');   title('CRA Sources')
subplot(5,1,3);  
champ_plot = [];
for i_champ = 1:3
  champ_plot = [champ_plot s_bar(s(i_champ),:)'/norm(s_bar(s(i_champ),:))];
end
plot(champ_plot);
title('Champ BEST Sources')
subplot(5,1,4);
champ_plot = [];
for i_champ = 1:3
  champ_plot = [champ_plot s_bar(ind_max(i_champ),:)'/norm(s_bar(ind_max(i_champ),:))];
end
plot(champ_plot); 
title('Champ MAX variance Sources')
subplot(5,1,5); hold on;         title('Champ @ true source locations')
plot(s_bar(rp(1, i_patch).sourceInd, :)/norm(s_bar(rp(1, i_patch).sourceInd, :)), 'b');
plot(s_bar(rp(2, i_patch).sourceInd, :)/norm(s_bar(rp(2, i_patch).sourceInd, :)), 'g');
plot(s_bar(rp(3, i_patch).sourceInd, :)/norm(s_bar(rp(3, i_patch).sourceInd, :)), 'r');


