classdef retino_patch_listener < handle
   properties
   end
   methods
      function obj = RetinoPatchListener(src)
         addlistener(src,'hiResCornerVert','PostSet', @src.hi_res_corner_vert_handler); % Add obj to argument list
%          addlistener(src,'timefcn','PostSet', @src.timefcn_handler); %
%          Add obj to argument list
         %          addlistener(src,'F',              'PostSet', @src.FHandler); % Add obj to argument list
      end
   end
end