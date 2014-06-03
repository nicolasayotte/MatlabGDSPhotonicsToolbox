function [ne] = numel(gstruc);
%function [ne] = numel(gstruc);
%
% Returns the number of elements in a structure.
%
% gstruc :   an object of the gds_structure class
% ne :       the number of elements in the structure gstruc
%

% Ulf Griesmann, NIST, June 2011

   ne = numel(gstruc.el);

end
