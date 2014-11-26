function s = rename(gstruc, sname);
%function s = rename(gstruc, sname);
%
% set property method for GDS structures
% can only be used to change the name of a structure
%
% gstruc :  a GDS structure
% sname :   the new name of the structure
%

if nargin < 2
   error ('gds_structure.rename :  missing argument(s).');
end

s = gstruc;
s.sname = sname;

return
