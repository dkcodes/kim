function [ out ] = coords2mesh( )
[data, coords] = dk_load_ph();
load('E:\raid\MRI\anatomy\Berkeley\DK\default_cortex.mat');
coords = coords([2 1 3],:);
coords = double(coords);


kVL = 1:msh.nVertexLR(1);							% LH indices
kVR = (msh.nVertexLR(1)+1):sum(msh.nVertexLR);		% RH indices

fWhite2Pial = 0.5;
if fWhite2Pial ~= 1
    msh.data.vertices = (1-fWhite2Pial)*msh.initVertices + fWhite2Pial*msh.data.vertices;
end
v = msh.data.vertices;
spos([2480 366 560 420])

l.v = v(:,kVL);
l.v_mrv = coords;
l.thresh = 1;

[i_map, d2] = nearpoints(l.v, l.v_mrv);
l.s = data(i_map);


interv = 10;
x = l.v(1, 1:interv:end);
y = l.v(2, 1:interv:end);
z = l.v(3, 1:interv:end);
w = l.s(1:interv:end);


