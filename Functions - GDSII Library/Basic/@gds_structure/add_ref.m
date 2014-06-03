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
      if ~all(cellfun(@(x)isa(x,'gds_structure'), struc))
         error('add_ref : at least one object in cell array is not a gds_structure.');
      end
      sname = topstruct(struc,1);
   else
      error('gds_structure.add_ref :  second argument must be a string or gds_structure(s).');
   end

   % 'adim' property present --> create aref elements
   if any( strcmp(varargin(1:2:length(varargin)), 'adim') ) % create aref elements
      rtype = 'aref';
   else
      rtype = 'sref';
   end
   
   % create reference elements
   rel = cellfun(@(x)gds_element(rtype, 'sname',x, varargin{:}), sname, 'UniformOutput',0);
   
   % add them to output structure
   ostruc.el    = [ostruc.el, rel];

end
