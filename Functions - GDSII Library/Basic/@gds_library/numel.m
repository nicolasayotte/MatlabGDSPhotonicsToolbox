function nume = numel(glib);
%function nume = numel(glib);
%
% Returns the number of elements in a library.
%
% glib :   an object of the gds_library class
% nume :   the number of elements in the library
%

% Ulf Griesmann, NIST, September 2013

% sum element numbers for each structure
nume = sum(cellfun(@(s)numel(s), glib.st));

return
