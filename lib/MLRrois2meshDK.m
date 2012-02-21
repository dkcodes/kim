function [iMap, cdata] = MLRrois2meshDK(cfg)
	global globalVar
    cdata = [];

	cortexType  = cfg.cortexType;
	% empty for defaultCortex.mat
	% 'hires' for hiresolution cortex source space.
    cortexType = 'hires';
	vAnatFile   = cfg.vAnatFile;
	mrmFile     = cfg.mrmFile;
	thresh      = cfg.thresh;
	fWhite2Pial = cfg.fWhite2Pial;
	ROIfiles    = cfg.ROIfiles;
	roiDir      = cfg.roiDir;
  
	if ~isfield(cfg,'plot'), cfg.plot    = false; end
	% add in layer checks?

	if ~exist('fWhite2Pial','var') || isempty(fWhite2Pial)
		fWhite2Pial = 0.5;	% layer1 ~ 0.3, layer3 ~ 1
	end
	if ~exist('thresh','var') || isempty(thresh)
		thresh = .5;			% mm
	end

	% mlrDir = uigetdir('','mrSESSION directory');

	% vAnatomy is IPR, assuming mmPerPix is also, i.e. agrees with coords not nodes ???
	if ~exist('vAnatFile','var') || isempty(vAnatFile)
		[mmPerPix,volSize,vAnatFile] = readVolAnatHeader;
	else
		mmPerPix = readVolAnatHeader(vAnatFile);
	end
	% disp(['reading header from ',vAnatFile])

	if exist('ROIfiles','var')
	else
		[ROIfiles,roiDir] = uigetfile(fullfile(roiDir,'*.mat'),'Standard Gray ROIs','multiselect','on');
	end


	if ischar(ROIfiles)
		ROIfiles = {ROIfiles};
	end

	%% PIR, inward normals, origin @ ASL corner of volume (mm?)
	if ~exist('mrmFile','var') || isempty(mrmFile)
		mrmPath = fullfile(fileparts(vAnatFile),'Standard','meshes');
		if isdir(mrmPath)
			[mrmFile,mrmPath] = uigetfile(fullfile(mrmPath,'defaultCortex.mat'),'cortex mesh mat-file');
		else
			[mrmFile,mrmPath] = uigetfile('defaultCortex.mat','cortex mesh mat-file');
		end
		if isnumeric(mrmFile)
			return
		end
	else
		[mrmPath,mrmFile,mrmExt] = fileparts(mrmFile);
		mrmPath = [mrmPath,filesep];
		mrmFile = [mrmFile,mrmExt];
	end


	% fprintf('cortex file = %s %s\n',mrmPath,mrmFile);
	% fprintf('loading ROIs from %s\n\n',roiDir);
	if ~isfield(globalVar, 'cortex')
% 		globalVar.cortex = load(fullfile(mrmPath,mrmFile));
		%     globalVar.meshHash = hashOld(globalVar.cortex.msh.data.vertices(:),'md5');
	end
% 	cortex = globalVar.cortex;
    cortex = load(fullfile(mrmPath,mrmFile));
	% meshHash = globalVar.meshHash;


	if fWhite2Pial ~= 1
		cortex.msh.data.vertices = (1-fWhite2Pial)*cortex.msh.initVertices + fWhite2Pial*cortex.msh.data.vertices;
	end
	cortex.msh.data.triangles = cortex.msh.data.triangles + 1;

	kVL = 1:cortex.msh.nVertexLR(1);												% LH indices
	kVR = (cortex.msh.nVertexLR(1)+1):sum(cortex.msh.nVertexLR);		% RH indices
	nFL = find(min(cortex.msh.data.triangles)>cortex.msh.nVertexLR(1),1,'first')-1;	% # LH faces

	cdata = repmat([0.75 0.75 0.75],size(cortex.msh.data.vertices,2),1);


	nROI = numel(ROIfiles);
	spc = ceil(sqrt(nROI));
	spr = ceil(nROI/spc);
	thresh2 = thresh^2;
	xd = 0.05:0.1:(10*ceil(thresh/10));
	ROIS(1:nROI) = struct('name','','viewType','','color',[],'coords',[],'created','','modified','','comments','',...
		'meshIndices',[],'date',datestr(now,0),'comment','converted with MLRrois2mesh.m');

	for iROI = 1:nROI
		% load ROI file, Vistasoft has IPR coords, PIR nodes
		roiCoords = load(fullfile(roiDir,ROIfiles{iROI}));		% in voxels, multiply my mmPerVox
%         roiCoords = load(fullfile(roiDir,'V2V-L.mat'));		% in voxels, multiply my mmPerVox
		roiCoords.ROI.coords = double(roiCoords.ROI.coords);
		for iDim = 1:3
			roiCoords.ROI.coords(iDim,:) = mmPerPix(iDim) * roiCoords.ROI.coords(iDim,:);
		end
		roiCoords.ROI.coords(:) = roiCoords.ROI.coords([2 1 3],:);
		[junk,ROIname] = fileparts(ROIfiles{iROI});
%         xind = find(cortex.msh.data.vertices(1,:)>150);
%         v = cortex.msh.data.vertices(:,xind);
%         if isempty(findobj(gca, 'type', 'patch'))
%             patch('faces', cortex.msh.data.triangles', 'vertices', cortex.msh.data.vertices');
%         end
%         axis vis3d equal;        hold on;
%         plot3(roiCoords.ROI.coords(1,:), roiCoords.ROI.coords(2,:), roiCoords.ROI.coords(3,:), '.', 'color', rand(1,3)); 
%         plot3(cortex.msh.data.vertices(1,iMap), cortex.msh.data.vertices(2,iMap), cortex.msh.data.vertices(3,iMap), '.g'); axis vis3d;
        
        %%
        % find nearest ROI vertex to each cortex vertex
		% include cortex vertex if distance is within threshold

		exploded.ROIname = explode('-', ROIname);
		switch exploded.ROIname{2}(1)
			case 'L'
				hemi = 'L';
				[iMap,d2] = nearpoints(cortex.msh.data.vertices(:,kVL),roiCoords.ROI.coords);
			case 'R'
				hemi = 'R';
				[iMap,d2] = nearpoints(cortex.msh.data.vertices(:,kVR),roiCoords.ROI.coords);
			otherwise
				hemi = 'LR';
				[iMap,d2] = nearpoints(cortex.msh.data.vertices,roiCoords.ROI.coords);		% roiCoords.ROI.coords(iMap) ~ cortex.msh.data.vertices
		end

		%     figure;
		%     
		%     roiCoords.ROI.coords
		% 	vROI = size(roiCoords.ROI.coords,2);
		% 	vUsed = numel(unique(iMap));
		% 	kGood = d2 < thresh2;
		% 	iMap(:) = 0;
		% 	iMap(kGood) = find(kGood);
		% 	nGood = sum(kGood);
		if isfield(cfg, 'closest') && isequal(cfg.closest, true)
			iMap = find(d2 ==min(d2));
		else
			iMap = find(d2 < thresh2);
		end
		d2 = d2(iMap);
		if hemi == 'R'
			iMap = iMap + cortex.msh.nVertexLR(1);
			% 		iMap(kGood) = iMap(kGood) + cortex.msh.nVertexLR(1);
		end
		d2 = sqrt(d2);
		%     fprintf('%s: hemi = %s, #gray nodes = %d, #vertices = %d, mean distance to mesh = %0.3g, std = %0.3g\n',...
			%         ROIname,hemi,size(roiCoords.ROI.coords,2),numel(iMap),mean(d2),std(d2))
		% 	fprintf('%s: hemi = %s, #gray nodes = %d (%0.2f%% mapped), mean distance to mesh = %0.3g, std = %0.3g\n',...
			% 		ROIname,hemi,vROI,vUsed/vROI*100,mean(d2(kGood)),std(d2(kGood)))

		% set ROI colors
		if ischar(roiCoords.ROI.color)
			switch roiCoords.ROI.color
				case 'r'
					cdata(iMap,:) = repmat([1 0 0],numel(iMap),1);
					% 			cdata(iMap(kGood),:) = repmat([1 0 0],nGood,1);
				case 'g'
					cdata(iMap,:) = repmat([0 1 0],numel(iMap),1);
					% 			cdata(iMap(kGood),:) = repmat([0 1 0],nGood,1);
				case 'b'
					cdata(iMap,:) = repmat([0 0 1],numel(iMap),1);
					% 			cdata(iMap(kGood),:) = repmat([0 0 1],nGood,1);
				case 'y'
					cdata(iMap,:) = repmat([1 1 0],numel(iMap),1);
					% 			cdata(iMap(kGood),:) = repmat([1 1 0],nGood,1);
				case 'c'
					cdata(iMap,:) = repmat([0 1 1],numel(iMap),1);
					% 			cdata(iMap(kGood),:) = repmat([0 1 1],nGood,1);
				case 'm'
					cdata(iMap,:) = repmat([1 0 1],numel(iMap),1);
					% 			cdata(iMap(kGood),:) = repmat([1 0 1],nGood,1);
				case 'k'
					cdata(iMap,:) = repmat([0 0 0],numel(iMap),1);
					% 			cdata(iMap(kGood),:) = repmat([0 0 0],nGood,1);
				case 'w'
					cdata(iMap,:) = repmat([1 1 1],numel(iMap),1);
					% 			cdata(iMap(kGood),:) = repmat([1 1 1],nGood,1);
				otherwise
					error('unknown ROI color')
			end
		else
			cdata(iMap,:) = repmat(roiCoords.ROI.color,numel(iMap),1);
			% 		cdata(iMap(kGood),:) = repmat(roiCoords.ROI.color,nGood,1);
		end

		if isequal(cfg.plot ,1)
			subplot(spr,spc,iROI)
			hist(d2,xd)
			%         	hist(d2(kGood),xd)
			xlim([0 thresh+0.2])
			title(ROIname)
		end

		ROIS(iROI).name = roiCoords.ROI.name;
		ROIS(iROI).viewType = roiCoords.ROI.viewType;
		ROIS(iROI).color = roiCoords.ROI.color;
		% 	ROIS(iROI).coords = [];
		if isfield(roiCoords.ROI,'created')
			ROIS(iROI).created = roiCoords.ROI.created;
			ROIS(iROI).modified = roiCoords.ROI.modified;
			ROIS(iROI).comments = roiCoords.ROI.comments;
		else
			ROIS(iROI).created = '';
			ROIS(iROI).modified = '';
			ROIS(iROI).comments = '';
		end
		ROIS(iROI).meshIndices =iMap;
		% 	disp(ROIS(iROI))
	end


	if cfg.plot == true
		ax = [subplot(121),0];
		P = [ patch('vertices',cortex.msh.data.vertices([3 1 2],kVL)','faces',cortex.msh.data.triangles(:,1:nFL)','facevertexcdata',cdata(kVL,:)), 0 ];
		L = [ light('position',[-512 128 128]), light('position',[512 128 128]), 0, 0 ];
		xlabel('+Right'),ylabel('+Posterior'),zlabel('+Inferior'),title('LH')
		% 	set(ax(1),'xlim',[40 150])
		set(ax(1),'xlim',[floor(min(cortex.msh.data.vertices(3,kVL))/10),ceil(max(cortex.msh.data.vertices(3,kVL))/10)]*10)
		ax(2) = subplot(122);
		P(2) = patch('vertices',cortex.msh.data.vertices([3 1 2],kVR)','faces',cortex.msh.data.triangles(:,(nFL+1):end)'-cortex.msh.nVertexLR(1),'facevertexcdata',cdata(kVR,:));
		L(3:4) = [ light('position',[-512 128 128]), light('position',[512 128 128]) ];
		xlabel('+Right'),ylabel('+Posterior'),zlabel('+Inferior'),title('RH')
		% 	set(ax(2),'xlim',[110 220])
		set(ax(2),'xlim',[floor(min(cortex.msh.data.vertices(3,kVR))/10),ceil(max(cortex.msh.data.vertices(3,kVR))/10)]*10)
		set(ax,'dataaspectratio',[1 1 1],'view',[0 0],'ydir','reverse','zdir','reverse','view',[0 0])
		set(ax,'ylim',[floor(min(cortex.msh.data.vertices(1,:))/10),ceil(max(cortex.msh.data.vertices(1,:))/10)]*10)
		set(ax,'zlim',[floor(min(cortex.msh.data.vertices(2,:))/10),ceil(max(cortex.msh.data.vertices(2,:))/10)]*10)
		set(P,'facecolor','interp','facelighting','gouraud','edgecolor',[0.5 0.5 0.5])
		set(L,'style','local','color',[1 1 0.75],'visible','off')

		UIm = uimenu('label','HemiViews');
		uimenu(UIm,'label','dorsal','callback',@changeView)
		uimenu(UIm,'label','ventral','callback',@changeView)
		uimenu(UIm,'label','medial','callback',@changeView)
		uimenu(UIm,'label','lateral','callback',@changeView)
		uimenu(UIm,'label','anterior','callback',@changeView)
		uimenu(UIm,'label','posterior','callback',@changeView)
		uimenu(UIm,'label','toggle view style','separator','on','callback',@toggleView)
		uimenu(UIm,'label','SAVE ROIs','separator','on','callback',@saveFuncROIs)
	end

function changeView(obj,varargin)
	switch get(obj,'label')
		case 'dorsal'
			set(ax,'view',[0 90])
		case 'ventral'
			set(ax,'view',[0 -90])
		case 'medial'

			set(ax(1),'view',[ 90 0])
			set(ax(2),'view',[-90 0])

		case 'lateral'

			set(ax(1),'view',[-90 0])
			set(ax(2),'view',[ 90 0])

		case 'anterior'
			set(ax,'view',[180 0])
		case 'posterior'
			set(ax,'view',[0 0])
	end
end

		function toggleView(varargin)
			if strcmp(get(L(1),'visible'),'off')
				set(L,'visible','on')
				set(P,'edgecolor','none')
			else
				set(L,'visible','off')
				set(P,'edgecolor',[0.5 0.5 0.5])
			end
		end

	function saveFuncROIs(varargin)
		if isdir(fullfile(mrmPath,'ROIs'))
			ROIdir = uigetdir(fullfile(mrmPath,'ROIs'),'ROI output directory');
		else
			ROIdir = uigetdir(mrmPath,'ROI output directory');
		end
		if ~isnumeric(ROIdir)
			for i = 1:nROI
				ROI = ROIS(i);
				ROIfile = fullfile(ROIdir,[ROI.name,'.mat']);
				disp(['writing ',ROIfile])
				save(ROIfile,'ROI')
			end
			set(gcbo,'visible','off')
		end
	end
end
