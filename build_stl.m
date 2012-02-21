options.make_orig     = 0;
options.make_overview = 0;
options.make_hi       = 0;
options.calc_hi_sep   = 0;
options.make_hi_jitter   = 0;
options.external_patch   = 1;
if options.make_orig == 1
%     fv_lh.vertices = rs.lh.orig.fv.vertex*1000;
%     fv_lh.faces = rs.lh.orig.fv.face;
%     patch2stl('tmp/subj37/lh', fv_lh, 'ascii')
%     return
%     fv_rh.vertices = rs.rh.orig.fv.vertex*1000;
%     fv_rh.faces = rs.rh.orig.fv.face;
%     patch2stl('tmp/subj37/rh', fv_rh, 'ascii')
%     return
end
if options.make_overview == 1
    folder = 'overview';
elseif options.make_hi == 1
    folder = 'hi';
else
    folder = '.';
end

for i_src = 1:3
    for i_patch = 1:size(rp,2)
        fv{i_src, i_patch}.vertices = rp(i_src, i_patch).fv.vertices*1000;
        fv{i_src, i_patch}.faces = rp(i_src, i_patch).fv.faces;
        str = sprintf('tmp/%s/V_%d_%d', folder, i_patch, i_src);
        if options.make_hi == 1
            patch2stl(str, fv{i_src, i_patch}, 'ascii')
        end
    end
end

if options.calc_hi_sep == 1
    for i_patch = 1:size(rp,2)
        p1 = mean(rp(1, i_patch).hi_res_norm.pos);
        p2 = mean(rp(2, i_patch).hi_res_norm.pos);
        p3 = mean(rp(3, i_patch).hi_res_norm.pos);
        sep(i_patch) = norm(p1-p2) + norm(p3-p2) + norm(p3-p1);
    end
    [junk, ind_sort] = sort(sep);
    count = 1;
    for i_patch = ind_sort
        for i_src = 1:3
            str = sprintf('tmp/%s/0%d_V_%d_%d', 'sorted', count,  i_patch, i_src)
            patch2stl(str, fv{i_src, i_patch}, 'ascii')
        end
        count = count + 1;
    end
end

if options.make_hi_jitter == 1
for i_src = 1:3
  for i_patch = 1:size(rp,2)
    fv{i_src, i_patch}.vertices = rp(i_src, i_patch).fv.vertices*1000;
    fv{i_src, i_patch}.faces = rp(i_src, i_patch).fv.faces;
    str = sprintf('tmp/%s/V_%d_%d', 'subj37', i_patch, i_src);
    patch2stl(str, fv{i_src, i_patch}, 'ascii')
  end
end
end


if options.external_patch   == 1
  for i_src = 1:3
    for i_patch = 1:2
      fv{i_src, i_patch}.vertices = rs.external_patch(1).fv.vertices*1000;
      fv{i_src, i_patch}.faces = rs.external_patch(2).fv.faces;
      str = sprintf('tmp/%s/Ext_%d_%d', 'subj37', i_patch, i_src);
      patch2stl(str, fv{i_src, i_patch}, 'ascii')
    end
  end
end

