function [rs] = gdsii_replicate(name, xy, grid, layer, dtype, prop, plex, elflags);
%function [rs] = gdsii_replicate(name, xy, grid, layer, dtype, prop, plex, elflags);
%
% gdsii_replicate :  defines a named structure containing a list of
%                    boundaries and then replicates the pattern on 
%                    a defined grid. A convenience function for
%                    array references.
%
% name   : name of the pattern (structure). The pattern can be
%          referenced by this name. The replicated pattern will
%          have the name REPL_<name>
% xy     : cell array of polygons (N x 2 matrices) or
%          compound boundary element that make up the pattern
% grid   : defines the grid over which the pattern is replicated
%             grid.nr : number of rows
%             grid.nc : number of columns
%             grid.dr : spacing between rows in user units
%             grid.dc : spacing between columns in user units
% layer  : (Optional) layer number. Default is layer 1. If xy is a
%          boundary element, the layer and all following arguments
%          are ignored.
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
% rs     : (Optional) a cell array of gds_structure objects.

% Initial version: Ulf Griesmann, NIST, January 2011
% removed gdsii_layer, U.G., Jan 2013

% check arguments
if nargin < 8, elflags = []; end;
if nargin < 7, plex = []; end;
if nargin < 6, prop = []; end;
if nargin < 5, dtype = []; end;
if nargin < 4, layer = []; end;
if nargin < 3, error('gdsii_replicate :  too few arguments.'); end;

if isempty(layer), layer = 1; end;
if isempty(dtype), dtype = 0; end;

% create the structure with the boundary elements
if isa(xy, 'gds_element')
   if is_etype(xy, 'boundary')
      be = xy;
   else
      error('gdsii_replicate :  argument xy must be a boundary element.');
   end
else
   be = gds_element('boundary', 'xy',xy, 'layer',layer, 'dtype',dtype, 'prop',prop, ...
                    'plex',plex, 'elflags',elflags);
end
bs = gds_structure(name, be);

% replicate it with an aref
arc = [0,0; ...
       grid.dc*grid.nc,0; ...
       0,grid.dr*grid.nr];
adim.row = grid.nr;
adim.col = grid.nc;
ar = gds_element('aref', 'sname',name, 'xy',arc, 'adim',adim);
as = gds_structure(['REPL_',name], ar);

% write to file or return
rs = {bs, as};

return
