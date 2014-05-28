function treeview(glib);
%function treeview(glib);
%
% treeview - display the structure hierarchy graph
%            of the structures contained in a gds_library
%            object.
%
% glib :  a gds_library object
%

% initial version, Ulf Griesmann, NIST, December 2011

% calculate the adjacency matrix of the structure tree
[A,N] = adjmatrix(glib.st);

% find top level structure(s) - they have no parents
pai = find(sum(A)==0);  % top parent index (or indices)

% display names beginning with the top
display_tree(A, N, pai, 0);

return

function display_tree(A, N, pai, indent);
%
% Function, called recursively, to display the structure 
% tree described by an adjacency matrix.
%
for p = pai

   % print parent name
   if indent
      blank(1:indent) = ' ';
      fprintf('%s%s\n', blank, N{p}); % parent
   else
      fprintf('%s\n', N{p}); % parent
   end
   
   % find children
   chi = find(A(p,:)>0);
   
   % next parent if there are no children
   if isempty(chi)
      continue
   end
   
   % otherwise print child generation
   for c = chi
      display_tree(A, N, c, indent+6);      
   end
   
end

return
