function gelms = find(gstruct, ffunc);
%function gelms = find(gstruct, ffunc);
%
% Find method for the gds_structure class. Can be used to find 
% elements with specific properties.
%
% gstruct :  a gds_structure object
% ffunc :    the handle of a function that is applied to each 
%            element contained in the structure gstruct. It returns 
%            either 0 or ~= 0. The elements for which ffunc returns
%            a value ~= o are returned in a cell array.
% gelms :    a cell array of gds_element objects for which
%            ffunc(gelm) ~= 0
% 
% Example:
%
%  gelms = find(gstruct, @(x) is_etype(x,'sref'));
%
% or:
%
%  gelms = find(gstruct, ...
%               @(x)(is_etype(x,'sref')|is_etype(x,'aref')) );
%
% returns all sref (and aref) elements contained in structure gstruct.
%

% Ulf Griesmann, NIST, November 2011

if nargin < 2
   error('gds_structure.find : missing argument.');
end

% return all elements with desired property
gelms = gstruct.el( cellfun(ffunc, gstruct.el) ~= 0 );
  
return  
