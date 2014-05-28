function [cout] = libraryfun(glib, func);
%function [cout] = libraryfun(glib, func);
%
% libraryfun : iterator for the gds_library class
%
% glib :  a gds_structure object
% func :  handle of a function that is applied
%         to each structure in the library
% cout :  cell array with function return values
%

% initial version, Ulf Griesmann, November 2011

cout = cellfun(func, glib.st, 'UniformOutput',0);

return
