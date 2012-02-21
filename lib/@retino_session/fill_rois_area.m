function obj = fill_rois_area(obj)
  rp = obj.retinoPatch;
  areas = zeros(numel(obj.a_source), numel(obj.a_patch));
  for i_source = 1:length(obj.a_source)
    ai_source = obj.a_source(i_source);
    for i_patch = 1:length(obj.a_patch)
      ai_patch = obj.a_patch(i_patch);
      t.rp = rp(ai_source, ai_patch);
      dip = t.rp.hi_res_norm.data;
      areas(ai_source, ai_patch) = sum(norm2(dip, 2));
      effective_areas(ai_source, ai_patch) = norm(sum(dip));
    end
    obj.rois.weight.visual_areas(ai_source) = sum(areas(ai_source, :));
    obj.rois.weight.effective_visual_areas(ai_source) = sum(effective_areas(ai_source, :));
  end
  obj.rois.weight.patches = areas;
  obj.rois.weight.effective_patches = effective_areas;
end
