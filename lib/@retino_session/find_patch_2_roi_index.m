function out = find_patch_2_roi_index(obj, i_patch, i_source)
	out = find(cellfun(@(x) x==i_patch,obj.design.patch2roi(:,1)) & cellfun(@(x) x==i_source,obj.design.patch2roi(:,2)));
end
