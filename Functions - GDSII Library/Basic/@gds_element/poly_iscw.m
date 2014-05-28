function cw = poly_iscw(belm);
%function cw = poly_iscw(belm);
%
% poly_iscw :  returns a vector with a flag for each
%              polgon in a boundary element. The flag
%              is 1 if the polygon has clockwise orientation,
%              0 otherwise.
%
% belm :  boundary element containing one ore more polygons
% cw   :  array with flags indicating the orientation of the
%         polygons.

% Initial version, Ulf Griesmann, NIST, November 2012

% check argument
if ~strcmp(get_etype(belm.data.internal), 'boundary')
   error('poly_iscw :  element must be a boundary element.');
end

% call mex function
cw = poly_iscwmex(belm.data.xy);

return

