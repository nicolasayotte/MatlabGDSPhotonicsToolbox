function gs = set(gstruc, varargin);
%function gs = set(gstruc, varargin);
%
% set property method for GDS structures
%

if (length (varargin) < 2 || rem (length (varargin), 2) ~= 0)
   error ('gds_element.set :  expecting property/value pair(s).');
end

gs = gstruc;

while length(varargin) > 1
  
   % get property/value pair
   prop = varargin{1};
   val = varargin{2};
   if ~ischar(prop)
      error('gds_structure.set :  property must be a string.');
   end
   gs.(prop) = val;
   varargin(1:2) = [];

end

return
