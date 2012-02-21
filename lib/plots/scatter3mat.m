function h = scatter3mat(mat, varargin)
n_varargin = numel(varargin);
x = mat(:,1);
y = mat(:,2);
z = mat(:,3);
arg_str = 'plot3(x, y, z';
varargin
for i_arg = 1:n_varargin
  if ischar(varargin{i_arg})
    arg_str = [arg_str ', ''' varargin{i_arg} ''''];
  else
    arg_str = [arg_str ', ' num2str(varargin{i_arg})];
  end
end
arg_str = [arg_str ');'];
eval(['h = ' arg_str]);
