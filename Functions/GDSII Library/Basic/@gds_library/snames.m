function [N,SN] = snames(glib)
%function [N,SN] = snames(glib)
%
% snames :  returns a cell array of the names of structures
%           contained in a library
%
% glib :    input gds_library object
% N :       cell array with structure names
% SN :      struct with structure name fields for 
%           efficient structure index lookup.

% initial version, August 2013, Ulf Griesmann

% find structure names
N = cellfun(@sname, glib.st, 'UniformOutput',0);

% create struct with GDS structure names
if nargout > 1
   idx = num2cell([1:length(glib.st)]);
   SN = cell2struct(idx, genvarname(N), 2);
end

return
