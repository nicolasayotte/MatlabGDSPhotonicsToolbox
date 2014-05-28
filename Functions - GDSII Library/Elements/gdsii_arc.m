function [pg] = gdsii_arc(arc, layer, dtype, prop, plex, elflags);
%function [pg] = gdsii_arc(arc, layer, dtype, prop, plex, elflags);
%
% gdsii_arc :  return the polygon approximation of an arc
%              or a circle (segment) as a gds_element object
% 
% arc    : structure with properties defining the arc
%          EITHER :
%             arc.r :   radius of INSIDE arc in user units. 
%                       arc.r == 0 creates a circle segment.
%             arc.c :   center coordinate of the arc; 1x2 matrix
%                       Default is [0,0].
%             arc.a1 :  start angle of arc in radians
%             arc.a2 :  end angle of arc in radians
%                       both angles must be from the interval [0,2pi]
%          OR :
%             arc.x1 :  start point of INSIDE arc
%             arc.x2 :  a point on the arc
%             arc.x3 :  end point of the arc
%
%          COMMON :
%             arc.w :   WIDTH of arc in user units
%             arc.e :   maximum approximation error in user units
%             arc.pap : polynomial approximation method. If == 0
%                       the polygon is inscribed in the arc, if == 1,
%                       the polygon has the same area
%                       as the arc, if == 2 the length of the
%                       polygon is equal to the arc
%                       length. 
%                       Default is 2 (equal length).  
% layer  : layer number. Default is 1.
% dtype  : (Optional) Data type number between 0..255. Layer number 
%          and data type together form a layer specification. 
%          DEFAULT is 0.
% prop   : (Optional) a cell array of  property number and property name pairs
%             prop.attr  : 1 .. 127
%             prop.value : string with up to 126 characters
% plex   : (Optional) plex number used for grouping of
%          elements. Should be small enough to use only the
%          rightmost 24 bits. A negative number indicates the start
%          of a plex group. E.g. -5 for the first element in the
%          plex, 5 for all the others.
% elflags: (Optional) an array (string) with the flags 'T' (template
%          data) and/or 'E' (exterior data).
%
% pg     : gds_element (boundary) with the arc boundary as a closed
%          polygon.
%

% Initial version: Ulf Griesmann, NIST, February 2011
% 

% check arguments
if nargin < 6, elflags = []; end
if nargin < 5, plex = []; end
if nargin < 4, prop = []; end
if nargin < 3, dtype = []; end
if nargin < 2, layer = []; end

if isempty(layer), layer = 1; end
if isempty(dtype), dtype = 0; end

if not( isfield(arc, 'r') || isfield(arc, 'x1') )
   error('gdsii_arc :  incomplete arc specification.');
end
if ~isfield(arc, 'w')
   error('gdsii_arc :  missing arc width field.');
end
if ~isfield(arc, 'e')
   error('gdsii_arc :  missing arc.e, max. approximation error field.');
end
if ~isfield(arc, 'pap')
   arc.pap = 2;
end

% calculate center, radius if 3 points are given
if isfield(arc, 'x1')
   [arc.c, arc.r] = circle_3point(x1, x2, x3);
end

% calculate the polygon approximation
if arc.r < 0
   error('gdsii_arc :  radius must be positive.');
end
if ~isfield(arc, 'c')
   arc.c = [0,0];
end

% first the outside arc, lowest angle to highest
rout = arc.w + arc.r;
[np, phi, rscal] = calc_vertex_num(rout, arc.a2 - arc.a1, arc.e, arc.pap);
R = repmat(rscal * rout, [np,1]);  % in polar coordinates
T = linspace(arc.a1, arc.a2, np)';
C = repmat(arc.c, [np,1]);
xy = pol_cart(T,R) + C;

% inside arc, highest angle to lowest
if arc.r > 0                % arc segment
   R = repmat(rscal * arc.r, [np,1]);
   xy = [xy; pol_cart(T(end:-1:1),R) + C];
else                        % circle segment
   if mod(arc.a2 - arc.a1, 2*pi)
      xy(end+1,:) = arc.c;
   end
end

% close the polygon
if any(xy(end,:) ~= xy(1,:))
   xy(end+1,:) = xy(1,:);
end

% return it
pg = gds_element('boundary','xy',xy, 'layer',layer, 'dtype',dtype, ...
                 'prop',prop, 'plex',plex, 'elflags',elflags);
return

%---------------------------------------------------------

function XY = pol_cart(T,R);
% convert from polar to cartesian coordinates
XY = [R.*cos(T), R.*sin(T)];

return

%---------------------------------------------------------
   
function [np, phi, Rfac] = calc_vertex_num(R, ang, E, pap);
% calculate number of vertices needed to approximate an arc by 
% a polygon
%
% R :    radius of the arc
% ang :  angle subtended by arc
% E :    maximum permissible approximation error
% pap :  polynom approximation method: 0 = polygon inscribed in
%        arc; 1 = arc area is equal to polygon area; 2 = polygon
%        length is equal to arch length
% np :   number of point in polygon approximation
% phi :  angle increment between vertices
% Rfac:  radius scale factor, depends on pap
%
phi  = acos(1 - E / R);
np   = ceil(ang / phi);  % integer number of vertices
phi  = ang / (np - 1);   % corrected angle

switch pap
  case 0  % polygon is inscribed in arc
     Rfac = 1;
     
  case 1  % polygon area equals arc area
     Rfac = sqrt( phi / sin(phi) );
     
  case 2  % polygon length equals arc length
     Rfac = 0.5 * phi / sin(phi/2);
     
otherwise
   error('unknown circle approximation method.');
end

return

%---------------------------------------------------------

function [C,R] = circle_3point(x1, x2, x3);
%function [C,R] = circle_3point(x1, x2, x3);
%
% circle_3point :  calculate center and radius of a circle
%                  defined by three points on the circle
%
% x1,x2,x3 :  three points (coordinate pairs)
% C :         Center of circle
% R :         Radius of circle
%

% initial version, Ulf Griesmann, NIST, September 2011

if nargin < 3
    error('must have three arguments.');
end

A = [x3(1) - x1(1), x3(2) - x1(2); ...
     x3(1) - x2(1), x3(2) - x2(2) ];
b = [0.5*(x3(1)^2 - x1(1)^2 + x3(2)^2 - x1(2)^2 ); ...
     0.5*(x3(1)^2 - x2(1)^2 + x3(2)^2 - x2(2)^2 )];
C = A\b;
R = sqrt( (x1(1) - C(1))^2 + (x1(2) - C(2))^2 );

return
