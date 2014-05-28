function oelm = add_poly(ielm, xy);
%function oelm = add_poly(ielm, xy);
%
% adds a polygon, or a cell array of polygons to a boundary
% or path elment. 
%
% ielm :  input boundary element
% xy :    a polygon or cell array of polygons
% oelm :  output element

% Initial version, Ulf Griesmann, December 2011
% extend to path elements; U. Griesmann, November 2012

% works only with boundary and path elements
if strcmp(get_etype(ielm.data.internal), 'boundary') || ...
   strcmp(get_etype(ielm.data.internal), 'path')

   % copy element
   oelm = ielm;

   % add polygon(s)
   if ~iscell(xy), xy = {xy}; end
   oelm.data.xy = [ielm.data.xy, xy];

else
  
  error('gds_element.add_poly :  input must be a boundary or path element.');

end

return
