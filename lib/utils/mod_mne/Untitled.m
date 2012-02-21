%The purpose of this script is to write the location of V1/V2/V3 region as a curvature file
%so that when we are cutting up occipital patches, we can get a good cut with a visual reference

cd('E:\raid\MRI\toolbox\kim\lib\utils\mod_mne');
load('E:\raid\MRI\anatomy\Berkeley\DK\default_cortex.mat')
nl = msh.nVertexLR(1);
c=zeros(nl,1);
% inds = find(~isnan(rs.lh.flat.vert_full(:,1)));
% c(inds) = 1;
c(rs.rois.V1_L) = 1;
c(rs.rois.V2D_L) = 1;
c(rs.rois.V2V_L) = 1;
c(rs.rois.V3D_L) = 1;
c(rs.rois.V3V_L) = 1;
o = mod_mne_write_curvature();
o.mne_write_surface('lh.V123.curv', ones(nl,1), 1, c);
system('cp lh.V123.curv "E:\raid\MRI\anatomy\FREESURFER_SUBS\DK_fs4\surf\"')


load('E:\raid\MRI\anatomy\Berkeley\DK\default_cortex.mat')
nr = msh.nVertexLR(2);
c=zeros(nr,1);
% inds = find(~isnan(rs.lh.flat.vert_full(:,1)));
% c(inds) = 1;
c(rs.rois.V1_R) = 1;
c(rs.rois.V2D_R) = 1;
c(rs.rois.V2V_R) = 1;
c(rs.rois.V3D_R) = 1;
c(rs.rois.V3V_R) = 1;
o = mod_mne_write_curvature();
o.mne_write_surface('rh.V123.curv', ones(nr,1), 1, c);
system('cp rh.V123.curv "E:\raid\MRI\anatomy\FREESURFER_SUBS\DK_fs4\surf\"')