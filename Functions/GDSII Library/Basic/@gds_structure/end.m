function leidx = end(gstruc, kide, nide); 
%function leidx = end(gstruc, kide, nide); 
%
% end method for the gds_structure class.
% Returns the index of the last element in the 
% gds_structure object
%
% gstruct :  a gds_structure object
% kide :     index in expression that uses the end keyword
%            (should be 1)
% nide :     total number of indices in the expression
%            (should be 1)
% leidx :    index of the last element 

if kide ~= 1 || nide ~= 1
   error('gds_structure :  has only one index.');
end

leidx = gstruc.numel;

return
