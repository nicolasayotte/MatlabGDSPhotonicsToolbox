function belm = poly_path(pelm);
%function belm = poly_path(pelm);
%
% converts a path element into an equivalent boundary element.
%
% pelm :  input path element
% belm :  output boundary element
%

% Initial version, Ulf Griesmann, December 2011
% Convert paths with multiple path segments; Ulf Griesmann, August2012
% Convert to new internal data structure; Ulf Griesmann, July 2013

% check if input is a path
if ~strcmp(get_etype(pelm.data.internal), 'path')
   error('gds_element.poly_path :  input must be path element.');
end

% create new element data structure and copy relevant properties
data.internal = new_internal('boundary');
plist = {'layer',get_element_data(pelm.data.internal,'layer'), ...
         'dtype',get_element_data(pelm.data.internal,'dtype')};
if has_property(pelm.data.internal, 'elflags')
   plist = [plist, {'elflags',get_element_data(pelm.data.internal)}];
end
if has_property(pelm.data.internal, 'plex')
   plist = [plist, {'plex',get_element_data(pelm.data.internal)}];
end
data.internal = set_element_data(data.internal, plist);

% convert paths
ptype = 0;
width = 0;
ext = struct('beg',0,'end',0);
if has_property(pelm.data.internal, 'ptype')
   ptype = get_element_data(pelm.data.internal, 'ptype');
end
if has_property(pelm.data.internal, 'width')
   width = get_element_data(pelm.data.internal, 'width');
else
   error('poly_path :  path must have width property.');
end
if has_property(pelm.data.internal, 'ext')
   ext = get_element_data(pelm.data.internal, 'ext');
end

data.xy = cell(1,length(pelm.data.xy));
for k=1:length(pelm.data.xy)
   data.xy{k} = path_to_boundary(pelm.data.xy{k}, ptype, width, ext);
end

% create new element
belm = gds_element([], data); 

return

% 
% local function to render paths as boundaries
%
function [bxy] = path_to_boundary(xy, ptype, width, ext);

% polygons on either side of path
xy1 = zeros(length(xy),2);
xy2 = zeros(length(xy),2);

% calculate boundaries along the path
if length(xy) == 2 % only two points on path
   [xs1,xs2] = line_shift(xy(1,:), xy(2,:), width/2); 
   xy1(1,:) = xs1; xy1(2,:) = xs2;
   [xs1,xs2] = line_shift(xy(1,:), xy(2,:), -width/2); 
   xy2(1,:) = xs1; xy2(2,:) = xs2;
else
   for k = 2:length(xy)-1
     
      % line "above" path
      if k==2 % first one
         [xs1,xs2] = line_shift(xy(k-1,:), xy(k,:), width/2); 
         xy1(1,:) = xs1;
      end
      [xs3,xs4] = line_shift(xy(k,:), xy(k+1,:), width/2);
      xy1(k,:) = line_intersection(xs1,xs2, xs3,xs4);
      xs1 = xs3; xs2 = xs4;
      
      % line "below" path
      if k==2 % first one
         [xs5,xs6] = line_shift(xy(k-1,:), xy(k,:), -width/2); 
         xy2(1,:) = xs5;
      end
      [xs7,xs8] = line_shift(xy(k,:), xy(k+1,:), -width/2);
      xy2(k,:) = line_intersection(xs5,xs6, xs7,xs8);
      xs5 = xs7; xs6 = xs8;
   end
   xy1(length(xy),:) = xs4;
   xy2(length(xy),:) = xs8;
end

% create path ends depending on path type
switch ptype
  
 case 0 % square path end, flush with end points 
    bxy = [xy1; xy2(end:-1:1,:); xy1(1,:)];
  
 case 1 % rounded path end
    a1 = semi_circle(xy1(1,:), xy2(1,:));
    a2 = semi_circle(xy2(end,:), xy1(end,:));
    bxy = [xy2; a2; xy1(end:-1:1,:); a1; xy2(1,:)];
  
 case 2 % square path end, extended past end points by half path width
    [xs1,xs2] = line_shift(xy1(1,:), xy2(1,:), -width/2);
    [xs3,xs4] = line_shift(xy1(end,:), xy2(end,:), width/2);
    bxy = [xs1; xs2; xy2(2:end-1,:); xs4; xs3; xy1(end-1:-1:2,:); xs1];
  
 case 4 % square path end, extended past end points by by variable extension
    [xs1,xs2] = line_shift(xy1(1,:), xy2(1,:), -ext.beg);
    [xs3,xs4] = line_shift(xy1(end,:), xy2(end,:), ext.end);
    bxy = [xs1; xs2; xy2(2:end-1,:); xs4; xs3; xy1(end-1:-1:2,:); xs1];
  
 otherwise
    error('gds_element.poly_path :  path type must be 0, 1, 2, or 4.');
end

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function P = line_intersection(p1, p2, p3, p4);
%
% calculate the point P at which two lines in the plane
% intersect. p1, p2 are two points on the first line, p3 
% and p4 two points on the second line
%
% http://en.wikipedia.org/wiki/Line-line_intersection

M = [p1-p2;p3-p4];
D = det(M);
if D
   A = det([p1',p2'])/D;
   B = det([p3',p4'])/D;
   P = [-B,A]*M;
else % lines are colinear
   P = p2;
end

return

function [xs1, xs2] = line_shift(x1, x2, d);
%
% translate a line segment defined by two points
% x1 and x2 by distance d along the normal vector

% vector connecting both points
X = x2 - x1;

% calculate a unit normal vector
if X(1) % line is not vertical
   N = [-X(2)/X(1),1];
else
   N = [1,0];
end
N = N / norm(N);

% There are two vectors normal to a line. We always 
% want the normal vector that results in a positive 
% exterior product of X and N:  X /\ N > 0
if det([X;N]) < 0
   N = -N;
end

% shift points
xs1 = x1 + d*N;
xs2 = x2 + d*N;

return

function A = semi_circle(x1, x2);
%
% A semi-circle of points connecting x1 to x2.
% The arc radius is half of the point
% distance. x1 and x2 are not part
% of the arc.

% number of points on arc (without ends)
np = 25;

% angle increment
ainc = pi/(np+1);

% calculate arc center
C = (x1 + x2) / 2;

% angle at point x1
X = x1 - C;
a0 = atan2(X(2),X(1));

% points on arc in polar coordinates
T = ainc * (1:np)' + repmat(a0,np,1);
R = repmat(norm(x1 - C),np,1);

% points on arc in Cartesian coordinates
A = [R.*cos(T), R.*sin(T)] + repmat(C,np,1);

return
