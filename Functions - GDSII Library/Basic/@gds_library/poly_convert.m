function [cstruc] = poly_convert(glib);
%function [cstruc] = poly_convert(glib);
% 
% converts path or box elements into 
% equivalent boundary elements. Text and
% node elements are removed. The structure
% hierarchy is preserved.
% 
% glib :   input gds_library object
% olib :   output gds_library object
%
% Example:
%        olib = poly_convert(glib);
%

% Initial version, Ulf Griesmann, December 2011

% create output library
olib = glib;
olib.st = cellfun(@poly_convert, glib.st, 'UniformOutput',0);

return
