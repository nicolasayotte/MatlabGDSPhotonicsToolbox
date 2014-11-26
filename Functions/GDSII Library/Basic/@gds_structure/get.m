function s = get(gstruc, p);
%function s = get(gstruc, p);
%
% get property method for GDS structures
%
% get(gstruc, 'sname') returns the structure name
% get(gstruc, 'numel') returns the number of elements in the
%                      structure
% get(gstruc, k)       returns the k-th element in the structure
% get(gstruc)          returns a cell array with all elements
%
switch nargin
    
  case 1
     s = gstruc.el;
   
  case 2  % get a specific property
   
     if ischar(p)
        s = gstruc.(p);
     
     elseif isnumeric(p)
        s = gstruc.el{p};

     else
        error('gds_structure.get :  argument must be string or index.');
     end
       
  otherwise
     error('gds_structure.get :  invalid number of arguments.');

end
  
return
