function s = get(glib, p);
%function s = get(glib, p);
%
% get property method for GDS libraries
% provided access to default properties
%

% called with only one argument, return a cell array with structures
switch nargin
  
 case 1
    s = glib.st;
   
 case 2  % get a specific property or structure
    if ischar(p)
       s = glib.(p);
    elseif isnumeric(p)
       s = glib.st{p};
    else
      error('gds_library.get :  property must be a string or numeric.');
   end
  
 otherwise
   error('gds_library.get :  invalid number of arguments.');
   
end
  
return
