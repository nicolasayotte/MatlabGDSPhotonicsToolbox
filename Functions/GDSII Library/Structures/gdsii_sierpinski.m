function [sf] = gdsii_sierpinski(tname, minel, maxel, ctrblk, pos, ang, layer);
%function [sf] = gdsii_sierpinski(tname, minel, maxel, ctrblk, pos, ang, layer);
%
% gdsii_sierpinski :  
%      returns a gds_structure object containing a Sierpinski
%      fractal composed of equilateral triangles. 
%
% tname :  (Optional) name of the top level structure. 
%          Default is SIERPINSKI_TOP.
% minel :  (Optional) length of the smallest (lowest level) 
%          triangle edge in user units. Default is 1.
% maxel :  (Optional) length of the largest triangle edge (top level) in
%          user units. Default is 10000. The pattern is built
%          up recursively from the smallest triangle. The smallest
%          edge length is therefore exact. The triangle is built up
%          until the edge length exceeds 'maxel';
% ctrblk : (Optional) when set to a value other than 0 the central
%          triangle will be black. Default is 0 (white center).
% pos :    (Optional) position of the left lower corner of the
%          pattern. Default is [0,0].
% ang :    (Optional) rotate the structure by an angle
%          'ang' in radians. Default is 0 (no rotation). 
% layer :  (Optional) layer to which the pattern is
%          written. Default is 1.
%
% sf :     cell array of gds_structure objects.
%         

% initial version: Ulf Griesmann, NIST, Feb 2011
% return gds_structure objects; U.G., NIST, November 2012
%

% check arguments
if nargin < 7, layer = []; end
if nargin < 6, ang = []; end
if nargin < 5, pos = []; end
if nargin < 4, ctrblk = []; end
if nargin < 3, maxel = []; end
if nargin < 2, minel = []; end
if nargin < 1, tname = []; end

if isempty(tname), tname = 'SIERPINSKI_TOP'; end
if isempty(minel), minel = 1; end
if isempty(maxel), maxel = 10000; end
if isempty(pos), pos = [0,0]; end
if isempty(ctrblk), ctrblk = 0; end
if isempty(ang), ang = 0; end
if isempty(layer), layer = 1; end


% black and white triangles use a slightly different algorithm
if ctrblk > 0
   [sf,lsname] = sierpinski_black(minel, maxel, pos, ang, layer);
else
   [sf,lsname] = sierpinski_white(minel, maxel, pos, ang, layer);
end

% move the pattern to its final location
strans.angle = 180 * ang / pi;
tls = gds_structure(tname);
tls = add_ref(tls, lsname, 'xy',pos, 'strans',strans);
sf{end+1} = tls;

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Sierpinski White
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [slist, lsname] = sierpinski_white(minel, maxel, pos, ang, layer);

% unit vector pointing to the top of the triangle
vt = [cos(pi/3),sin(pi/3)];

% write the smallest triangle as a boundary
tr = [0,0; minel,0; minel*vt; 0,0];
tre = gds_element('boundary', 'xy',tr, 'layer',layer);
slist = { gds_structure('TRIANG_0', tre) };  % initial triangle structure

% now recursively build the Sierpinski triangle
cwid = minel;  % current triangle width
level = 1;
while cwid < maxel
  
   % define the next level of the structure
   cname = sprintf('TRIANG_%d', level);   % current level name
   pname = sprintf('TRIANG_%d', level-1); % previous level name
   sre = gds_element('sref', 'sname',pname, 'xy',[[0,0;cwid,0];cwid*vt]);
   cwstr = sprintf('%.1f', cwid);    % width string
   lbl = gdsii_ptext(cwstr, cwid*[0.625,0.725], 0.1*cwid, layer);
   slist{end+1} = gds_structure(cname, sre, lbl);
   
   % next level
   level = level + 1;
   cwid = cwid * 2;    % width of the new structure
   
end

% return the name of the last structure
lsname = cname;

return


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Sierpinski Black
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [slist, lsname] = sierpinski_black(minel, maxel, pos, ang, layer);

% unit vector pointing to top of basic triangle
vt = [cos(pi/3),sin(pi/3)];

% unit vectors pointing to corners of black triangle
vb = [0.5,0];                       % bottom corner of triangle
vl = 0.5 * [cos(pi/3),sin(pi/3)];   % left corner
vr = 0.5 * [1+cos(pi/3),sin(pi/3)]; % right corner

% write the smallest triangle as a boundary
tr = 2 * minel * [vb; vr; vl; vb];
tre = gds_element('boundary', 'xy',tr, 'layer',layer);
slist = { gds_structure('TRIANG_0', tre) };  % initial triangle structure

% now recursively build the Sierpinski triangle
cwid = 2 * minel;  % current triangle width
level = 1;
while cwid < maxel
  
   % define the next level of the structure
   cname = sprintf('TRIANG_%d', level);   % current level name
   pname = sprintf('TRIANG_%d', level-1); % previous level name
   sre = gds_element('sref', 'sname',pname, 'xy',[[0,0;cwid,0];cwid*vt]);
   cwid = cwid * 2;                       % next largest triangle
   nle = gds_element('boundary', 'xy',cwid*[vb; vr; vl; vb], 'layer',layer);
   slist{end+1} = gds_structure(cname, sre, nle);
   
   % next level
   level = level + 1;
   
end

% return the name of the last structure
lsname = cname;

return
