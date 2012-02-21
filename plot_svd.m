toggle_svd_average_type =2;

if isequal(toggle_svd_average_type, 1)
v1 = rs.sim.true.timefcn{1};
v2 = rs.sim.true.timefcn{2};
v3 = rs.sim.true.timefcn{3};

t = results_svd(1).svd.all.t;
t1 = t(:,1);
t2 = t(:,2);
t3 = t(:,3);

k1 = v1/t1';
k2 = v2/t2';
k3 = v3/t3';

h.p(1) = plot(v1, 'r');
h.p(2) = plot(k1*t1, 'k');
h.p(3) = plot(v2, 'r:');
h.p(4) = plot(k2*t2, 'k:');
%h.p(5) = plot(v3, 'r:');
%h.p(6) = plot(k3*t3, 'k:');
saveas(h.p, 'linewidth', 3);
hold on;
elseif isequal(toggle_svd_average_type, 2)
  clear t;
v(:,1) = rs.sim.true.timefcn{1};
v(:,2) = rs.sim.true.timefcn{2};
v(:,3) = rs.sim.true.timefcn{3};

  for i_subj = 1:21
    t(:,:, i_subj) = results_svd(i_subj).svd.data.t;
  end
  a_subj = [1:13 16:19];
  a_subj = [4:8 16:19]
  mean_t = mean(t(:,:,a_subj),3);

  colors = [.8 .2 .2; 0 0 0];
  markers = {'-' ':' '-.'}; 
  subplot(4,1,1)
  hold on;
  for i_source = rs.a_source
    k(i_source) = v(:, i_source)'/mean_t(:, i_source)';
    h.p(i_source) = plot(v(:, i_source), markers{i_source});
    h.p(numel(rs.a_source) + i_source) = plot(mean_t(:, i_source)*k(i_source),  markers{i_source});
  end
  set(h.p, 'linewidth', 3);
  set(h.p(1:3), 'color', [.8 .1 .1]);
  set(h.p(4:end), 'color', [0 0 0] );

  for i_subj = a_subj
    subplot(4,1,2); hold on;
    for i_source = 1 
    k(i_source) = v(:, i_source)'/squeeze(t(:, i_source, i_subj))';
    h.p(i_source) = plot(v(:, i_source), markers{i_source});
    h.p(numel(rs.a_source) + i_source) = plot(squeeze(t(:, i_source, i_subj))*k(i_source),  markers{i_source});
    end 
    subplot(4,1,3); hold on;
    for i_source = 2 
    k(i_source) = v(:, i_source)'/squeeze(t(:, i_source, i_subj))';
    h.p(i_source) = plot(v(:, i_source), markers{i_source});
    h.p(numel(rs.a_source) + i_source) = plot(squeeze(t(:, i_source, i_subj))*k(i_source),  markers{i_source});
    end   
    subplot(4,1,4); hold on;
    for i_source = 3 
    k = v(:, i_source)'/squeeze(t(:, i_source, i_subj))';
    h.p(i_source) = plot(v(:, i_source), markers{i_source});
    h.p(numel(rs.a_source) + i_source) = plot(squeeze(t(:, i_source, i_subj))*k,  markers{i_source});
    end
  end
  
    
end
