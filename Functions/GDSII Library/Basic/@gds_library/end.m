function lsidx = end(glib, kide, nide); 
%function lsidx = end(glib, kide, nide); 
%
% end method for the gds_library class.
% Returns the index of the last element in the 
% gds_structure object
%
% gstruct :  a gds_library object
% kide :     index in expression that uses the end keyword
%            (should be 1)
% nide :     total number of indices in the expression
%            (should be 1)
% lsidx :    index of the last structure 

if kide ~= 1 || nide ~= 1
   error('gds_library :  has only one index.');
end

lsidx = glib.numst;

return
