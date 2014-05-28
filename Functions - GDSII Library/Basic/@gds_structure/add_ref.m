function [ostruc] = add_ref(istruc, struc, varargin);
%function [ostruc] = add_ref(istruc, struc, varargin);
%
% Adds reference elements to structures
%
% istruc :   a gds_structure object
% struc :    a gds_structure object, a cell array of gds_structure
%            objects, or a structure name to be referenced
% varargin : variable/property pairs to describe the placement of
%            the gds_structure. The default position 'xy' is [0,0].
% ostruc :   gds_structure containing the input structure with the added
%            reference elements.
%
% Example:
%           struc = add_ref(struc, {beauty,truth} 'xy',[1000,1000]);
%

% Initial version, Ulf Griesmann, December 2011

% copy input to output
ostruc = istruc;

% get the structure name
if ischar(struc)
   sname = {struc};   
elseif isa(struc, 'gds_structure')
   sname = {struc.sname};
elseif iscell(struc)
   sname = topstruct(struc,1);
else
   error('gds_structure.add_ref :  second argument must be a string or gds_structure(s).');
end

% create reference elements
for k = 1:length(sname)
   if is_aref(varargin)
      ostruc.el{end+1} = gds_element('aref', 'sname',sname{k}, varargin{:});
   else
      ostruc.el{end+1} = gds_element('sref', 'sname',sname{k}, varargin{:});
   end
end
ostruc.numel = ostruc.numel + length(sname);

return


function is = is_aref(va)
%
% if one of the properties is 'adim', the element is
% an aref element
%
for k=1:2:length(va)
   if strcmp(va{k},'adim')
      is = logical(1);
      return
   end
end

is = logical(0);

return
