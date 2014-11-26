function s = set(glib, varargin);
%function s = set(glib, varargin);
%
% set property method for GDS elements
%

if (length (varargin) < 2 || rem (length (varargin), 2) ~= 0)
   error ('gds_library.set :  expecting property/value pair(s).');
end

s = glib;

while length(varargin) > 1
  
   % get property/value pair
   prop = varargin{1};
   val = varargin{2};
   if ~ischar(prop)
      error('gds_library.set :  property name must be a string.');
   end
   s.(prop) = val;
   varargin(1:2) = [];

end

return
