function [A,N] = adjmatrix(S);
%function [A,N] = adjmatrix(S);
%
% return the adjacency matrix and a list of structure
% names for a cell array S of gds_structure objects 
%
% S : cell array of gds_structure objects
% A : adjacency matrix - describes the structure tree
% N : a cell array with structure names
%
% NOTE:
% The adjacency matrix is a representation of the parent-child
% relationships within the structure tree. Structures are assigned
% an index in the cell array N. In the adjacency matrix each row 
% index r corresponds to the structure name N{r}. Each non-zero
% column in row r is the index of a child structure, i.e. a structure
% that is referenced by N{r}. Conversely, the columns of the adjacency
% matrix can be used to find the parent(s) of a structure N{c}, i.e. 
% the indices of those structures that contain references to N{c}.

% Initial version, Ulf Griesmann, December 2011
% converted to sparse matrix, Ulf Griesmann, November 2012

% find all structure names
N = cellfun(@sname, S, 'UniformOutput',0);

% compute the adjacency matrix
A = sparse(length(N),length(N));

for k = 1:length(N) % loop over structures
  
   % find names of all referenced structures in the k-th structure
   R = find_ref(S{k});
   
   % look up indices of all reference names in name list N
   A(k,:) = ismember(N,R);
   
end

return
