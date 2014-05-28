function nums = numst(glib);
%function nums = numst(glib);
%
% An alias for the length method
% Returns the number of structures in a library.
%
% glib :   an object of the gds_library class
% nums :   the number of structures in the library
%

% Ulf Griesmann, NIST, June 2011

nums = glib.numst;

return
