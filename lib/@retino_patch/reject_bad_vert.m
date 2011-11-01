function [p_norm] = reject_bad_vert(o)
% Due to whatever reason (most likely flattening)
% There is a problem where a patch picks 3d points from
% very far away locations. I want to eliminate these

% The offenders are (by the way verts are indexed,
% in sequence, so find the first offender and remove all that follows.
p1 = o.hi_res_norm.pos;
p2 = p1(2:end, :); 
p1(end,:) = [];


p1 = p1'; p2 = p2';
p_diff = p1 - p2;
for i_vert = 1:size(p1,2)
  p_diff_norm(i_vert) = norm(p_diff(:,i_vert));
end


% find first instance where the the jump is mad 
a = find(p_diff_norm > .035);
if ~isempty(a)
  good_vert = 1:(a-1);
  % fix all the verts
  o.hiResVert = o.hiResVert(good_vert,:);
end
