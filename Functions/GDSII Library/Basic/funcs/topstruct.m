function [ts] = topstruct(cas, bcell);
%function [ts] = topstruct(cas, bcell);
%
% topstruct :  return the name(s) of the top structure(s)
%              in a cell array of gds_structure objects
%
% cas :   a cell array of gds_structure objects
% bcell : if == 1, a cell array is returned, even when only
%         one top level structure is found.
% ts :    name of the top structure or cell array with names if 
%         the library has more than one top level structure

% Initial version, Ulf Griesmann, December 2012

% check arguments
if nargin < 2, bcell = []; end

if isempty(bcell), bcell = 0; end

% calculate the adjacency matrix of the structure tree
[A,N] = adjmatrix(cas);

% find top level structure name(s)
ts = N(find(sum(A)==0));
if length(ts) == 1 && ~bcell
  ts = ts{1}; 
end

return
