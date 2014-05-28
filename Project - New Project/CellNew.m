%% StraightWG
% Author : Abdul
% Creation date : 16/04/2014
% The entire programs is in microns.


%% Initialize Cell Parameters
tp = cd; cd ..; addpath(genpath(cd)); cd(tp);     % add path to every folder of the library
[log, cad, cellname, topcell, layerMap] = InitializeCell();


%% Load GDS Library References
refs = [];


%% Define Cellref Objects
phW = Waveguide([0.5, 3.5], [layerMap.FullCore, layerMap.FullClad], 5, 3.5);


%% Create the cell
% Initialize the cell inputs and outputs
infoIn = [];  % inputs
infoOut = [];  % outputs


% Get a cursor
infoIn = CursorInfo([0, 0], 0, 1);
[topcell, infoOut, infoIn] = PlaceRect(topcell, infoIn, 100, phW.w, phW.layer, phW.dtype);
[topcell, infoOut] = PlaceArc(topcell, infoOut, 90, phW.r, phW.w, phW.layer, phW.dtype);


infoIn = CursorInfo([0, 3 * phW.sp; 0, 4 * phW.sp; 0, 5 * phW.sp; 0, 6 * phW.sp], 0, 1);

[topcell, infoOut, infoIn] = PlaceRect(topcell, infoIn, 100, phW.w, phW.layer, phW.dtype);
% [topcell, infoOut] = PlaceArc(topcell, infoOut, 90, phW.r, phW.w, phW.layer, phW.dtype);
% [topcell, infoOut] = PlaceArc(topcell, infoOut, 90, phW.r, phW.w, phW.layer, phW.dtype, 'group', true);
[topcell, infoOut] = PlaceArc(topcell, infoOut, 90, phW.r, phW.w, phW.layer, phW.dtype, 'group', true, 'distance', [5 7 9]);
[topcell, infoOut] = PlaceArc(topcell, infoOut, 90, phW.r, phW.w, phW.layer, phW.dtype, 'group', true, 'distance', phW.sp);

[topcell, infoOut] = PlaceSBend(topcell, infoOut, 30, -10, phW.r, phW.w, phW.layer, phW.dtype, 'group', true);
[topcell, infoOut] = PlaceSBend(topcell, infoOut, 30, 0, phW.r, phW.w, phW.layer, phW.dtype, 'group', true, 'distance', 10);
[topcell, infoOut] = PlaceSBend(topcell, infoOut, 40, 0, phW.r, phW.w, phW.layer, phW.dtype, 'group', true, 'distance', phW.sp, 'align', 'top');

% This line writes the total length each cursor has gone over at the output positions
totalLengths = infoIn.length + infoOut.length;
strEl = arrayfun(@(x, y, len) gds_element('text', 'text', ['Length : ' num2str(len, '%01.1f')], ...
   'xy', [x, y], 'layer', layerMap.TXT(1)), infoOut.pos( : , 1), infoOut.pos( : , 2), totalLengths( : , 1), 'UniformOutput', 0);
topcell = add_element(topcell, strEl');


%% Save GDS and .mat cell information
FinalizeCell(cad, cellname, topcell, refs, infoIn, infoOut, log);

