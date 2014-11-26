function L = rename(glib, lname);
%function L = rename(glib, lname);
%
% changes the library name of a gds_library object
%
% glib  :  a GDS library object
% lname :   the new name of the library
%

if nargin < 2
   error ('gds_library.rename :  missing argument(s).');
end

L = glib;
L.lname = lname;

return
