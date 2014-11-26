function [ts] = topstruct(glib);
%function [ts] = topstruct(glib);
%
% topstruct :  return the name(s) of the top structure(s)
%              in a gds_library object
%
% glib : a gds_library object
% ts :   name of the top structure or cell array with names if 
%        the library has more than one top level structure

% Initial version, Ulf Griesmann, December 2011

% calculate the adjacency matrix of the structure tree
[A,N] = adjmatrix(glib.st);

% find top level structure name(s)
naml = N(find(sum(A)==0));
if length(naml) == 1
   ts = naml{1};
else
   ts = naml;
end

return
