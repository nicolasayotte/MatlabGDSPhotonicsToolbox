function beo = poly_cw(bei, makecw);
%function beo = poly_cw(bei, makecw);
%
% poly_cw :  all polygons in a boundary element with 
%            counter-clockwise (CCW) orientation are 
%            changed to clockwise (CW) orientation and
%            vice versa.
%
% bei :    input boundary element.
% makecw : if 1, output polygons will all have CW orientation.
%          if 0, output polygons will have CCW orientation.
%          Default is 1.
% beo :    output boundary element.
%

% Initial version, Ulf Griesmann, NIST, November 2012

% check arguments
if ~strcmp(get_etype(bei.data.internal), 'boundary')
   error('poly_cw :  element must be a boundary element.');
end
if nargin < 2, makecw = 1; end

% determine orientation
cw = poly_iscwmex(bei.data.xy);

% find the polygons to change
if makecw
   pch = find(cw==0); % find all CCW polygons
else
   pch = find(cl~=0); % find all CW polygons
end

% create output element and flip orientations
beo = bei;
for k = pch
   T = beo.data.xy{k};
   beo.data.xy{k} = T(end:-1:1,:);
end

return
