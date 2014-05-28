function belm = poly_text(telm, height);
%function belm = poly_text(telm, height);
%
% renders a text element as a boundary element with
% the text defined as polygons.
%
% telm :    input text element
% height :  text height in user units
% belm :    output boundary element
%
% NOTE:
% -----
% GDS II text elements are not designed to be rendered as polygons.
% They appear to have originally been intended for drawning by a
% plotter device. The height property of text elements (not in the
% GDS definition !) is used to size the text elements for rendering
% with polygons. The default height is 10 user units (see:
% gds_element.m).
%
% * This function is not very efficient because it renders each string twice;
% first to determine the length in user units, then to render it at the correct
% location in the desired orientation. This is acceptable because there are only
% few text elements in any given layout.
%
% * the magnification factor of the optional strans record is ignored.

% Initial version, Ulf Griesmann, December 2011

% check if input is a text
if ~strcmp(get_etype(telm.internal), 'text')
   error('gds_element.poly_text :  input must be text element.');
end

% defaults
if nargin < 2, height = 10; end

% create new internal structure and copy relevant properties
data.internal = new_internal('boundary');
layer = get_element_data(telm.data.internal,'layer');
plist = {'layer',layer, ...
         'dtype',get_element_data(telm.data.internal,'ttype')};
if has_property(data.internal, 'elflags')
   plist = [plist, {'elflags',get_element_data(telm.data.internal,'elflags')}];
end
if has_property(data.internal, 'plex')
   plist = [plist, {'plex',get_element_data(telm.data.internal,'plex')}];
end
data.internal = set_element_data(data.internal, plist);

% render text string as cell array of boundaries to get width
[tchars, twidth] = gdsii_ptext(telm.data.text, [0,0], height, 0, 1);

% determine origin depending on justification
XY = telm.data.xy;  % text location
switch get_element_data(telm.data.internal, 'horj')
 case 1
    XY(1) = XY(1) - twidth/2;
 case 2
    XY(1) = XY(1) - twidth;
end
switch get_element_data(telm.data.internal, 'verj')
 case 0
    XY(2) = XY(2) - height;
 case 1
    XY(2) = XY(2) - height/2;
end

% get angle from strans and convert to radians
ang = 0;
if has_property(telm.data.internal, 'angle') 
   ang = pi * get_element_data(telm.data.internal, 'angle') / 180; 
end

% render the string at the correct place
data.xy = gdsii_ptext(telm.data.text, XY, height, layer, ang, 1);

% create output element
belm = gds_elmement([], data);

return
