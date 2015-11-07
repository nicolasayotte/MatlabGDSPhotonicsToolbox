function [bms] = gdsii_bitmap(bmap, pixel, sname, layer, dtype);
%function [bms] = gdsii_bitmap(bmap, pixel, sname, layer);
%
% gdsii_bitmap : The function creates a GDS II structure containing
%                a bitmap composed of black and white pixels.
%
% bmap :   matrix with elements 1 for black pixels and 0 for white
%          pixels. When empty, a cell array containing
%          gds_structure objects is returned.
% pixel :  A structure variable containing pixel width and height
%          in user units
%               pixel.width
%               pixel.height
%               pixel.rsname  (Optional)
%          pixel.rsname is a string with the name of a referenced
%          structure. By default, a pixel is defined by a square
%          boundary. Optionally, a pixel can be defined by an
%          external structure. The pixel is then placed on a grid
%          defined by pixel.width and pixel.height
% sname :  (Optional) name of the created structure. Default is 'BITMAP'.
% layer :  (Optional) layer to which the pattern is
%          written. Default is 1.
% bms :    a cell array of gds_structure objects
%
% initial version: Ulf Griesmann, NIST, Feb 2011
% removed global variable gdsii_layer, Jan 2012, U.G.
%

% check arguments
if nargin < 5, dtype = []; end;
if nargin < 4, layer = []; end;
if nargin < 3, sname = []; end;
if nargin < 2
    error('missing argument(s)');
end

if isempty(sname), sname = 'BITMAP'; end;
if isempty(layer), layer = 1; end;
if isempty(dtype), dtype = 0; end;
if ~isfield(pixel, 'width')
    error('Missing field /width/ in variable /pixel/.');
end
if ~isfield(pixel, 'height')
    pixel.height = pixel.width;
end

% define a square pixel if no external structure is used
if ~isfield(pixel, 'rsname')
    pixel.rsname = 'SQUARE_PIXEL';
    bm_pixel = [0,0; pixel.width,0; pixel.width,pixel.height; 0,pixel.height; 0,0];
end

% create the pixel structure
pixs = gdsii_pattern(pixel.rsname, bm_pixel, layer, dtype);

% replicate the pixel at every position where the bitmap ~= 0
% also make sure the image has the correct orientation
[ir,ic] = find(bmap(end:-1:1,:)' ~= 0); % find black pixels
xy = [pixel.width*(ir-1), pixel.height*(ic-1)];
repe = gds_element('sref', 'sname',pixel.rsname, 'xy',xy);
reps = gds_structure(sname, repe);

% write to file or return
bms = {pixs, reps};

return
