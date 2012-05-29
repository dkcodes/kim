function init_session_patch(o)
n_source = numel(o.a_source);
n_patch = numel(o.a_patch);
c1 = jet(n_patch*n_source);
c{1} = c1(1:32,:); %c = c(randperm(16),:);
c{2} = c1(33:end,:);
c{3} = c1(65:end,:);
for i_source = 1:length(o.a_source)
    ai_source = o.a_source(i_source);
    fprintf('Building >> Source %g ::: Patch ', i_source);
    for i_patch = 1:length(o.a_patch)
        ai_patch = o.a_patch(i_patch);
        
        rp(ai_source, ai_patch) = retino_patch;
        rp(ai_source, ai_patch).session = o;
        t.rp = rp(ai_source, ai_patch);
        
        % Finds in the design matrix the roi file list corresponding to (iPatch, iSource)
        t.rp.ind      = ai_patch;
        t.rp.area     = ai_source;
        switch o.options.patch_boundary.type
            case 'curve'
                t.rp.hemi = o.patchset(ai_source, ai_patch).hemi;
                t.rp.hiResVert = o.patchset(ai_source, ai_patch).hi_res_vert;
            case 'corner'
                t.rp.hiResCornerVert             = o.default_corner_vert.patch(ai_source, ai_patch).hiResCornerVert;
                t.rp.hemi                        = o.default_corner_vert.patch(ai_source, ai_patch).hemi;
                t.rp.fill_flat_vert();
                t.rp.fill_surf_from_corner();
            otherwise
                error('Unknown rs.options.patch_boundary.type');
        end
        t.rp.calculate_forward_hi();
        t.rp.calculate_forward_hi_jitter_norm();
        %       t.rp.calculate_forward_hi_true(fwdtrue);
        fprintf('%02g ', i_patch);
        try
            t.rp.faceColor = c{i_source}(ai_patch,:);
            t.rp.edgeColor = c{i_source}(ai_patch,:);
        catch
            t.rp.faceColor = [rand rand rand];
            t.rp.edgeColor = [rand rand rand];
        end
    end
    fprintf(' ::: %0.1g sec \n', toc);
end
% temporary: create external parietal source
% a=get_vert_from_asc(fullfile(o.dirs.berkeley, 'lh.par.asc')); a = a(:,1);
% b=get_vert_from_asc(fullfile(o.dirs.berkeley, 'rh.par.asc')); b = b(:,1);
% e_rp(1) = retino_patch;
% e_rp(1).session = o;
% e_rp(1).hemi = 'L';
% e_rp(1).hiResVert = a;
% e_rp(1).calculate_forward_hi();
% e_rp(2) = retino_patch;
% e_rp(2).session = o;
% e_rp(2).hemi = 'R';
% e_rp(2).hiResVert = b;
% e_rp(2).calculate_forward_hi();
% o.external_patch = e_rp;

o.retinoPatch = rp;
% o.fill_pt();
end
