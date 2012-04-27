function set_vis(h, tog)
for i_h = 1:numel(h)
   this.h = h(i_h);
   if (nargin<2) || isequal(tog, true)
       set(this.h, 'visible', 'on')
   else
       set(this.h, 'visible', 'off');
   end
end