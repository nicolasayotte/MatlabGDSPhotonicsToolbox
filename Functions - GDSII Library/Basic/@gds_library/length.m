function len = length(glib);
%function len = length(glib);
%
% Length function for the gds_library class;
% returns the number of structures in a library.
%
% glib :   an object of the gds_library class
% len :    the number of structures in the library
%

% Ulf Griesmann, NIST, June 2011

len = glib.numst;

return
