function out = field_2_mat(obj, s_field)
tmp = [];
for i_obj = 1:numel(obj)
  if iscell(s_field)
    t = obj(i_obj);
    for i_s = 1:numel(s_field)
      t = t.(s_field{i_s});
    end
   tmp = [tmp; t]; 
  end
end
out = tmp;
