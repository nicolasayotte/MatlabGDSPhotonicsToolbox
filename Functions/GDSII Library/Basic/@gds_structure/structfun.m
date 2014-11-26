function [cout] = structfun(gstruc, func);
%function [cout] = structfun(gstruc, func);
%
% structfun : iterator for the gds_structure class
%
% gstruc :  a gds_structure object
% func :    handle of a function that is applied
%           to each element in the structure
% cout :    cell array with function return values
%

% initial version, Ulf Griesmann, November 2011

cout = cellfun(func, gstruc.el, 'UniformOutput',0);

return
