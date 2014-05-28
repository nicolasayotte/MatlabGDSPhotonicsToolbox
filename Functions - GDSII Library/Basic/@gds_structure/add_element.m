function [ostruc] = add_element(istruc, gelm);
%function [ostruc] = add_element(istruc, gelm);
%
% Add elements or other structures to structures
%
% istruc :   a gds_structure object
% gelm :     a gds_element object or a cell array of gds_element
%            objects
% ostruc :   gds_structure containing the new elements or structure
%

% Initial version, Ulf Griesmann, December 2011

% copy input to output
ostruc = istruc;

% and add the new element
if isa(gelm, 'gds_element');
   ostruc.el{end+1} = gelm;
   
elseif iscell(gelm)
   ostruc.el = [ostruc.el,gelm];
   
else
   error('gds_structure.add : input must be gds_element, gds_structure, or cell array.');
end

ostruc.numel = numel(ostruc.el);

return
