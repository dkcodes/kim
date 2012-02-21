clear r;
close all;

figure(1)
subplot(2,1,1); 
a = randn(640,3);
a = a - repmat(min(a), 640, 1);
a = a./repmat(max(a), 640, 1)*2;
a = a - 1;
hist(a)
xlabel('Correlation')
a=ylabel('W'); set(a, 'FontSize', 20)
subplot(2,1,2); 
a = randn(640,3);
a = a - repmat(min(a), 640, 1);
a = a./repmat(max(a), 640, 1)*2;
a = a - 1;
hist(a)
xlabel('Correlation')
a=ylabel('WE'); set(a, 'FontSize', 20)



figure(2)
expt = {'q_ideal'};
titles = {'Ideal Conditions'};
for i_expt = 1:numel(expt)
    this.expt = expt{i_expt};
    filename = fullfile('out', this.expt, 'mat', 'results_svd.mat');
    load(filename);
    r{ i_expt } = results_svd;
end
i_subplot = 1;
for i_expt = 1:numel(expt)
    subplot(2,1, i_subplot);
    clear t;
    for i = 1:20 
        t(i,:) = r{i_expt}(i).true.T_all.corr-eps; 
    end; 
    t = repmat(t,32,1);
    x_bar = -1:.05:1;
    y_bar =histc(t, x_bar);
    bar(x_bar, y_bar, 'barwidth', 2)
    title(titles{i_expt})
    a=ylabel('W'); set(a, 'FontSize', 20)
    xlim([-1 1]); ylim([0 650]); 
    subplot(2,1, i_subplot+1);
    t = []; 
    for i = 1:20 
        t = [t; r{i_expt}(i).true.T.corr.patch']; 
    end; 
    t = t-eps;
    x_bar = -1:.05:1;
    y_bar =histc(t, x_bar);
    bar(x_bar, y_bar, 'barwidth', 2)
    xlim([-1 1]); ylim([0 650]); 
    a=ylabel('WE'); set(a, 'FontSize', 20)
    i_subplot = i_subplot + 1;
end

%Jittered Norms
figure(3)
expt = {'q_jittered_norm'};
% titles = {'30 Deg'};
for i_expt = 1:numel(expt)
    this.expt = expt{i_expt};
    filename = fullfile('out', this.expt, 'mat', 'results_svd.mat');
    load(filename);
    r{ i_expt } = results_svd;
end
i_subplot = 1;
for i_expt = 1:numel(expt)
    subplot(1,2, i_subplot);
    t = []; 
    for i = 1:20 
        t = [t; r{i_expt}(i).true.T.corr.patch']; 
    end; 
    x_bar = -1:.05:1;
    y_bar =histc(t, x_bar);
%     bar(x_bar, y_bar, 'barwidth', 2)
    boxplot(t); ylim([0 1]);
    a=ylabel('Correlation( T_{true}, T_{BEM} )');
    title('F_{BEM}')
    set(gca, 'xtick', [1 2 3], 'XTickLabel', {'V1'; 'V2'; 'V3'})
%     set(a, 'FontSize', 20)
%     xlim([-1 1]); ylim([0 650]); 

    subplot(1,2, i_subplot+1);
        clear t;
    for i = 1:20 
        t(i,:) = r{i_expt}(i).true.T_all.corr; 
    end; 
    t = repmat(t,32,1);
    x_bar = -1:.05:1;
    y_bar =histc(t, x_bar);
%     bar(x_bar, y_bar, 'barwidth', 2)
    boxplot(t); ylim([0 1]);
    a=ylabel('Correlation( T_{true}, T_{emp} )'); 
%     set(a, 'FontSize', 20)
    title('F_{emp}')
    set(gca, 'xtick', [1 2 3], 'XTickLabel', {'V1'; 'V2'; 'V3'})
%     xlim([-1 1]);   ylim([0 650]); 
    i_subplot = i_subplot + 1;
    
end

%%
% Bad localization
figure(4)
expt = {'q_move'};
titles = {'30 Deg'};
for i_expt = 1:numel(expt)
    this.expt = expt{i_expt};
    filename = fullfile('out', this.expt, 'mat', 'results_ind.mat');
    load(filename);
end
close all;
clear t;
i_subplot = 1;
n_move = size(results_ind, 2);
n_dir  = size(results_ind, 1);
n_subj = size(results_ind(1,1).results_svd, 2);
n_patch = size(results_ind(1,1).results_svd(1).true.T.corr.patch,2);
for i_move = 1:size(results_ind, 2)
  for i_dir = 1:size(results_ind, 1)
    for i_subj = 1:n_subj
      t(:, i_dir, i_move, i_subj) = results_ind(i_dir, i_move).results_svd(i_subj).true.T_all.corr;
    end;
  end
end
tt = [];
for i_move = 1:size(results_ind, 2)
  tt{i_move} = [];
  for i_dir = 1:size(results_ind, 1)
    for i_subj = 1:n_subj
      tt{i_move} = [tt{i_move} squeeze(t(:, i_dir, i_move, i_subj))];
    end
  end
end
% for i_tt = 1:numel(tt)
%   subplot(2,n_move, i_subplot+n_move);
%   x_bar = -1:.05:1;
%   y_bar = histc(repmat(tt{i_tt}, 1, n_patch)', x_bar);
%   bar(x_bar, y_bar, 'barwidth', 2);
%   xlim([-1 1]); ylim([0 600]);
%   if i_subplot == 1;
%     a=ylabel('WE'); set(a, 'FontSize', 20)
%   end
%   xlabel([num2str(i_tt) ' mm'])
%   i_subplot = i_subplot + 1;
% end
subplot(2,3,1);boxplot([tt{1}(1,:)' tt{2}(1,:)' tt{3}(1,:)' tt{4}(1,:)' tt{5}(1,:)' tt{6}(1,:)']);  ylim([-1 1]);
h=findobj(gca,'tag','Outliers'); delete(h)
title('F_{emp}, V1')
set(gca, 'xtick', [1:6], 'XTickLabel', [0:5]); xlabel('mm shift')
ylabel('Correlation( T_{true}, T_{emp} )')

subplot(2,3,2);boxplot([tt{1}(2,:)' tt{2}(2,:)' tt{3}(2,:)' tt{4}(2,:)' tt{5}(2,:)' tt{6}(2,:)']);  ylim([-1 1]);
h=findobj(gca,'tag','Outliers'); delete(h)
title('F_{emp}, V2')
set(gca, 'xtick', [1:6], 'XTickLabel', [0:5]); xlabel('mm shift')

subplot(2,3,3);boxplot([tt{1}(3,:)' tt{2}(3,:)' tt{3}(3,:)' tt{4}(3,:)' tt{5}(3,:)' tt{6}(3,:)']);  ylim([-1 1]);
h=findobj(gca,'tag','Outliers'); delete(h)
title('F_{emp}, V3')
set(gca, 'xtick', [1:6], 'XTickLabel', [0:5]); xlabel('mm shift')




clear t
for i_move = 1:size(results_ind, 2)
  for i_dir = 1:size(results_ind, 1)
    for i_subj = 1:n_subj
      t(:, i_dir, i_move, i_subj, :) = results_ind(i_dir, i_move).results_svd(i_subj).true.T.corr.patch;
    end;
  end
end
tt = [];
for i_move = 1:size(results_ind, 2)
  tt{i_move} = [];
  for i_dir = 1:size(results_ind, 1)
    for i_subj = 1:n_subj
      tt{i_move} = [tt{i_move} squeeze(t(:, i_dir, i_move, i_subj, :))];
    end
  end
end
i_subplot = 1;
% for i_tt = 1:numel(tt)
%   subplot(2, n_move, i_subplot);
%   x_bar = -1:.05:1;
%   y_bar = histc(tt{i_tt}', x_bar);
%   bar(x_bar, y_bar, 'barwidth', 2);
%   xlim([-1 1]); ylim([0 600]);
%   if i_subplot == 1;
%     a=ylabel('W'); set(a, 'FontSize', 20)
%   end
%   i_subplot = i_subplot + 1;
% end
subplot(2,3,4);boxplot([tt{1}(1,:)' tt{2}(1,:)' tt{3}(1,:)' tt{4}(1,:)' tt{5}(1,:)' tt{6}(1,:)']); ylim([-1 1]);
h=findobj(gca,'tag','Outliers'); delete(h)
ylabel('Correlation( T_{true}, T_{BEM} )')
title('F_{BEM}, V1')
set(gca, 'xtick', [1:6], 'XTickLabel', [0:5]); xlabel('mm shift')


subplot(2,3,5);boxplot([tt{1}(2,:)' tt{2}(2,:)' tt{3}(2,:)' tt{4}(2,:)' tt{5}(2,:)' tt{6}(2,:)']); ylim([-1 1]);
h=findobj(gca,'tag','Outliers'); delete(h)
title('F_{BEM}, V2')
set(gca, 'xtick', [1:6], 'XTickLabel', [0:5]); xlabel('mm shift')


subplot(2,3,6);boxplot([tt{1}(3,:)' tt{2}(3,:)' tt{3}(3,:)' tt{4}(3,:)' tt{5}(3,:)' tt{6}(3,:)']); ylim([-1 1]);
h=findobj(gca,'tag','Outliers'); delete(h)
title('F_{BEM}, V3')
set(gca, 'xtick', [1:6], 'XTickLabel', [0:5]); xlabel('mm shift')



% i_subplot = 1;
% for i = 1:10
%     subplot(2,1, i_subplot);
%     t = []; 
%     for i = 1:20 
%         t = [t; r{i_expt}(i).true.T.corr.patch']; 
%     end; 
%     x_bar = -1:.05:1;
%     y_bar =histc(t, x_bar);
%     bar(x_bar, y_bar, 'barwidth', 2)
%     a=ylabel('W'); set(a, 'FontSize', 20)
%     xlim([-1 1]); ylim([0 650]); 
% 
%     subplot(2,1, i_subplot+1);
%     clear t;
%     for i = 1:20 
%         t(i,:) = r{i_expt}(i).true.T_all.corr; 
%     end; 
%     t = repmat(t,32,1);
%     x_bar = -1:.05:1;
%     y_bar =histc(t, x_bar);
%     bar(x_bar, y_bar, 'barwidth', 2)
%     a=ylabel('WE'); set(a, 'FontSize', 20)
%     title(titles{i_expt})
%     xlim([-1 1]); ylim([0 650]); 
%     i_subplot = i_subplot + 1;
%     
% end

%%
%external source
figure(5)
expt = {'q_ext_src_str_1', 'q_ext_src_rand_str_pos_neg', 'q_ext_src_str_1_delays'};
expt = {'q_ext_src_str_1'};
titles = {'Constant', 'Variable Amplitude', 'Variable Latency'};
for i_expt = 1:numel(expt)
    this.expt = expt{i_expt};
    filename = fullfile('out', this.expt, 'mat', 'results_svd.mat');
    load(filename);
    r{ i_expt } = results_svd;
end

i_subplot = 1;
for i_expt = 1:numel(expt)
    subplot(1,2, i_subplot);
    t = []; 
    for i = 1:20 
        t = [t; r{i_expt}(i).true.T.corr.patch']; 
    end; 
    boxplot(t);
    ylabel('Correlation( T_{true}, T_{BEM} )')
    title('F_{BEM}')
    set(gca, 'xtick', [1 2 3], 'XTickLabel', {'V1'; 'V2'; 'V3'})
    h=findobj(gca,'tag','Outliers'); delete(h)
%     x_bar = -1:.1:1;
%     y_bar =histc(t, x_bar);
%     bar(x_bar, y_bar, 'barwidth', 2)
% %     hist(t);
%     title(titles{i_expt})
%     xlim([-1 1]); ylim([0 650]);
%     if i_subplot == 1
%       a=ylabel('W'); 
% %       set(a, 'FontSize', 20)
%     end
    subplot(1,2, i_subplot+1);
    clear t; 
    for i = 1:20 
        t(i,:) = r{i_expt}(i).true.T_all.corr; 
    end; 
    t = repmat(t,32,1);
    boxplot(t)
    ylabel('Correlation( T_{true}, T_{emp} )')
    title('F_{emp}')
    set(gca, 'xtick', [1 2 3], 'XTickLabel', {'V1'; 'V2'; 'V3'})
    h=findobj(gca,'tag','Outliers'); delete(h)
%     x_bar = -1:.1:1;
%     y_bar =histc(t, x_bar);
%     bar(x_bar, y_bar, 'barwidth', 2)
%     xlim([-1 1]); ylim([0 650]); 
%     if i_subplot == 1
%       a= ylabel('WE'); set(a, 'FontSize', 20)
%     end
    i_subplot = i_subplot + 1;
end



return
%%
close all
a=[(100-0*abs(randn(640,1))) (100-4*abs(randn(640,1))) (100-6*abs(randn(640,1)))]/100;
b=[(100-0*abs(randn(640,1))) (100-1.5*abs(randn(640,1))) (100-1.5*abs(randn(640,1)))]/100;
subplot(1,2,1)
boxplot(a); ylim([0 1])
set(gca, 'xtick', [1 2 3],'XTickLabel', {'1/80'; '1/60'; '1/40'})
ylabel('Correlation( T_{true}, T_{BEM} )')
title('F_{BEM}')
subplot(1,2,2)
boxplot(b); ylim([0 1])
title('F_{emp}')
set(gca, 'xtick', [1 2 3], 'XTickLabel', {'1/80'; '1/60'; '1/40'})
ylabel('Correlation( T_{true}, T_{EMP} )')

sgcf([680 752 603 226]);