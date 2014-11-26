%% Custom profile Integrated Bragg Gratings
% Author : Alexandre Delisle- Simard                       Creation date : 12/04/2014
% Co-author : Nicolas Ayotte

% The entire programs is in microns.


%% Initialize Cell Parameters
tp = cd; cd ../Functions/; addpath(genpath(cd)); cd(tp);     % add path to every folder of the library
[log, cad, cellname, topcell, layerMap] = InitializeCell();


%% Define Cell Objects
fA = FiberArray(250, 30 * sqrt(3), 30, 55, 30, 20);
phW = Waveguide([0.5, 3.5], [layerMap.FullCore, layerMap.FullClad], 5, 3.5);

braggProfile = load('braggProfile');
bragg = BraggFromProfile(braggProfile.spatialVector * 1e6, braggProfile.spatialPhase, braggProfile.apodization, ...
   [3 * 0.283; 2 * 0.283; 0.283], [0.1, 0], 0.26, [0.8, 5], 0, [3; 2; 1], phW.layer, phW.dtype, ...
   'apodizationType', 'superposition', 'apodizationFrequency', 1.2, 'widthIsAverage', true);

taperLen = 50;
taper = Taper(bragg, phW);


%% Load GDS Library References
refs = [];
refs = GetRefsFloorplan(refs);


%% Create the cell
info = CursorInfo(cumsum(repmat([0, 5], 3, 1)), 0, [1, 2.78]);
info.pos( : , 1) = 50;

[topcell, info, infoIn] = PlaceStructure(topcell, info, bragg);
[topcell, info] = PlaceTaper(topcell, info, taper, 50);
[topcell, infoOut] = PlaceRect(topcell, info, 2650 - info.length( : , 1), phW.w, phW.layer, phW.dtype);
[topcell, infoIn] = PlaceTaper(topcell, infoIn, taper, 50);


%% Save GDS and .mat cell information
FinalizeCell(cad, cellname, topcell, refs, infoIn, infoOut, log);

