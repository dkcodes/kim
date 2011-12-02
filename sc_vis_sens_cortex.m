figure_seed = randi(1e8);

toggle_show_all_elec = 0;
toggle_show_per_patch = 1;
toggle_show_layout = 0;
subplot_cfg.row = 4
subplot_cfg.col = numel(rs.a_patch)/subplot_cfg.row;


if toggle_show_layout
  layout_filename = fullfile(rs.dirs.mne, 'Axx_c001.layout')
  [elec_chan, x, y] = textread(layout_filename, '%n %n %n %*n %*n %*s %*s', 'headerlines', 1);
  x = x * 1e-3;
  y = y * 1e-3;
else
  hpts_filename = fullfile(rs.dirs.mne, 'Axx_c001.hpts')
  [type, elec_chan, x, y, z] = textread(hpts_filename, '%s %s %n %n %n', 'headerlines', 9);
  x = x * 1e-3;
  y = y * 1e-3;
  z = z * 1e-3;
end



if toggle_show_all_elec
  a_chan = 1:128;
  colors = jet(numel(a_chan));
  for i_chan = 1:numel(a_chan)
    chan = a_chan(i_chan);
    subplot(1,3,1)
    %  h_elec=plot3(x(chan),y(chan),z(chan), 'o', 'color', colors(i_chan,:)); hold on
    h_elec=plot3(x(chan),y(chan),z(chan), 'k.');
    hold on;
    copyobj(h_elec, s2);
    copyobj(h_elec, s3);
  end
  subplot(s1); axis vis3d equal;view(s1, [0 90])
  subplot(s2); axis vis3d equal;view(s2, [0 0])
  subplot(s3); axis vis3d equal;view(s3, [90 0])
else
  a_chan = rs.a_chan;
  if toggle_show_per_patch
    i_subplot = 0;
    for i_patch = 1:numel(rs.a_patch)
      ai_patch = rs.a_patch(i_patch); i_subplot = i_subplot + 1;
      for i_source = 1:numel(rs.a_source)
        ai_source = rs.a_source(i_source);
        trp = rp(ai_source, ai_patch);
        figure(figure_seed + 1000+ i_source);
        h_subplot(ai_source, ai_patch) = ...
                  subplot(subplot_cfg.row, subplot_cfg.col, i_subplot); hold on;
        F = trp.F.mean.norm;
        F_max_abs = max(abs(F));
        % [68 75 81 94]
        if toggle_show_layout
          scatter2sc(x(a_chan), y(a_chan), F(a_chan), [-.01 .01]);
        else   
          scatter3sc(x(a_chan), y(a_chan), z(a_chan), F(a_chan), [-.05 .05]/(numel(rs.a_patch)/15));
          view([0 0]); axis vis3d equal;
        end
      end
    end
  end
end
if toggle_show_layout
  return
end




if toggle_show_per_patch
  i_subplot = 0;
  for i_patch = 1:numel(rs.a_patch)
    ai_patch = rs.a_patch(i_patch); i_subplot = i_subplot + 1;
    for i_source = 1:numel(rs.a_source)
      ai_source = rs.a_source(i_source);
      
      trp = rp(ai_source, ai_patch);
      pos = trp.hi_res_norm.pos;
      
      F = trp.F.mean.norm;
      Fvar(i_source, i_patch) = sqrt(sum(F.^2));
      Fweight(i_source, i_patch) = sum(trp.F.weight);
      quiver_norm(i_source, i_patch) = norm(sum(trp.hi_res_norm.data.*repmat(trp.F.weight, 1, 3)));
      dip.pos = trp.hi_res_norm.pos;
      dip.norm = trp.hi_res_norm.data;
      sp{i_source, i_patch} = mean(dip.pos);
      sn{i_source, i_patch} = sum(dip.norm); 
      sn{i_source, i_patch} = ...
        sn{i_source, i_patch}/norm(sn{i_source, i_patch})*Fweight(i_source, i_patch)*1000;
      tsp = sp{i_source, i_patch};
      tsn = sn{i_source, i_patch};
      for i_src_fig = 1:3
        figure(figure_seed + 1000+ i_src_fig);
        subplot(subplot_cfg.row, subplot_cfg.col, i_subplot); set(gca, 'Visible', 'off');
        h_patch(ai_source, ai_patch) = plot3(pos(:,1), pos(:,2), pos(:,3), '.', ...
        'color', trp.faceColor); hold on;
        h_quiver(ai_source, ai_patch) = quiver3(tsp(1), tsp(2), tsp(3), tsn(1), tsn(2), tsn(3), ...
        'linewidth', 2, 'color', trp.faceColor);
        text(0, 0, sprintf('(%g : %g)', ai_source, ai_patch ) )
        view([0 0]); axis vis3d equal;
      end
    end
  end
end

return


a_patch = intersect(p.patch_def.right, p.patch_def.up);
a_patch = intersect(p.patch_def.right, p.patch_def.down);
%a_patch = [p.patch_def.right];
for i_patch = 1:numel(a_patch)
  ai_patch = a_patch(i_patch);
  for i_source = 1:3
    trp = rp(i_source, ai_patch);
    pos = trp.hi_res_norm.pos;
    subplot(1,3,1);
    h(i_source) = plot3(pos(:,1), pos(:,2), pos(:,3), '.', ...
    'color', trp.faceColor); hold on;
    axis vis3d equal;
    copyobj(h(i_source), s2);
    copyobj(h(i_source), s3);
    title([num2str(i_source) ' :: ' num2str(ai_patch)]);
  end
end
toggle_draw_cortex = 1;
if toggle_draw_cortex == 1
  n_dec = 10;
  rr = rs.fwd.src(1).rr;
  rx = rr(1:n_dec:end, 1); ry = rr(1:n_dec:end, 2); rz = rr(1:n_dec:end, 3);
  plot3(rx, ry, rz, '.')
  rr = rs.fwd.src(2).rr;
  rx = rr(1:n_dec:end, 1); ry = rr(1:n_dec:end, 2); rz = rr(1:n_dec:end, 3);
  plot3(rx, ry, rz, '.')
  axis vis3d equal
end
str_fig = sprintf('sens_cortex_%s', subj_id);
filename_fig = fullfile('.', 'out', g.dirs, 'fig',   str_fig);
%saveas(gcf, filename_fig);

