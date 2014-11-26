function [olib] = add_struct(ilib, istruc);
%function [olib] = add_struct(ilib, istruc);
%
% Add structures to gds_library objects
%
% ilib :    a gds_library object
% istruc :  a gds_structure object or a cell array of gds_structure
%           objects
% olib :    gds_library containing old and new structures

% test arguments
if nargin < 2
   error('add : missing argument.');
end

% copy input to output
olib = ilib;

% and add the new element
if isa(istruc, 'gds_structure');
   olib.st{end+1} = istruc;
elseif iscell(istruc)
   for k = 1:length(istruc)   
      if ~isa(istruc{k}, 'gds_structure') 
         error('gds_library.add :  input cell array member is not a gds_structure.');
      end
      olib.st{end+1} = istruc{k}; 
   end
else
   error('gds_structure.add : argument must be gds_structure or cell array.');
end

olib.numst = numel(olib.st);

return
