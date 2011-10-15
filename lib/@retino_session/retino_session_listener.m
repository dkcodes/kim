classdef retino_session_listener < handle
   properties
   end
   methods
		 function obj = RetinoSessionListener(src)
			 addlistener(src,'ctf','PostSet', @src.timefcn_handler); %
			 %          addlistener(src,'retinoPatch','PostSet', @src.timefcn_handler); %
		 end
	 end
 end



