function struc = treecopy(glib, sname);
%function struc = treecopy(glib, sname);
%
% treecopy :  copies a structure and all
%             referenced structures from a library
%             (aka. "deep copy").
%
% glib :   input gds_library object
% sname :  name of structure to be copied
% struc :  cell array of gds_structure objects 

% Initial version, Ulf Griesmann, December 2011

% indices of structures in subtree
subtree_ind = [];

% compute adjacency matrix of input library
[A,N] = adjmatrix(glib.st);

% find index of structure 'sname'
si = find( ismember(N,{sname}) > 0);
if isempty(si)
   error(sprintf('Structure >>> %s <<< not found in library.', sname));
end

% find the indices of all children
find_children(A, si);

struc = glib.st(unique(subtree_ind));

   function find_children(A, pai);
      %
      % Recursively find all children of node si.
      % The resulting set of indices is returned through
      % a global variable because I couldn't figure out 
      % how to initialize the return value of a recursive
      % function.
      %
      for p = pai
  
         % add index to array
         subtree_ind(end+1) = p;
    
         % find the children
         chi = find(A(p,:)>0);
    
         % no more children
         if isempty(chi)
            continue
         end
    
         % look for the next generation
         for c = chi
            find_children(A, c);
         end

      end
   end % nested function

end
