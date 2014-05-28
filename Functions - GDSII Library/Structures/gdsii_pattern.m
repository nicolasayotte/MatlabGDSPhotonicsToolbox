function [scb] = gdsii_pattern(sname, xy, layer, dtype, prop, flex, elflags);
%function [scb] = gdsii_pattern(sname, xy, layer, dtype, prop, flex, elflags);
%
% gdsii_pattern :  a convenience function that creates a gds_structure object 
%                  containing a compound boundary element. Makes it easier to 
%                  create layouts that are described by numerous polygons.
%
%
% sname  : name of the gds_structure object. 
% xy     : polgon or cell array of polygons (N x 2 matrices).
% layer  : (Optional) layer number. Default is layer 1.
% dtype  : (Optional) Data type number between 0..255. Layer number 
%          and data type together form a layer specification. 
%          DEFAULT is 0.
% prop   : (Optional) a property number and property name pair
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
% scb :    a gds_structure object containing the boundary elements.

% Initial version: Ulf Griesmann, NIST, January 2011
% removed gdsii_layer, U.G., Jan 2013

% global variables
global gdsii_uunit;
global gdsii_dbunit;

% check arguments
if nargin < 7, elflags = []; end
if nargin < 6, plex = []; end
if nargin < 5, prop = []; end
if nargin < 4, dtype = []; end
if nargin < 3, layer = []; end
if nargin < 2
   error('gdsii_pattern :  need at least two arguments.');
end

if isempty(layer), layer = 1; end;
if isempty(dtype), dtype = 0; end;

% create boundary element
be = gds_element('boundary', 'xy',xy, 'layer',layer, 'dtype',dtype, ...
                  'prop',prop, 'plex',plex, 'elflags',elflags);

% create structure
scb = gds_structure(sname, be);

return
