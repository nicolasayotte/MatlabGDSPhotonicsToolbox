%% StraightWG
% Author : Abdul
% Creation date : 16/04/2014
% The entire programs is in microns.


%% Initialize Cell Parameters
tp = cd; cd ..; addpath(genpath(cd)); cd(tp);     % add path to every folder of the library
[log, cad, cellname, topcell, layerMap] = InitializeCell();


%% Load GDS Library References
refs(1).filename = '../Library/GratingCouplerDummy.gds';
refs(1).cellname = 'GratingCouplerDummy';
refs = GetRefsFloorplan(refs);


%% Define Cellref Objects
phW = Waveguide([0.5, 3.5], [layerMap.FullCore, layerMap.FullClad], 5, 5);
fA = FiberArray(250, 30 * sqrt(3), 30, ceil(refs.floorplan.size(1)/5) * 5, ceil(refs.floorplan.size(2)/5) * 5, 20);


%% Create the cell
% Initialize the cell inputs and outputs
infoIn = [];  % inputs
infoOut = [];  % outputs

% Get a cursor information
posy = (0 : 4 * phW.sp : 4 * 8 * phW.sp)';
posx = 0 * posy;

infoIn = CursorInfo([posx, posy], 0, 1);

[topcell, infoOut] = PlaceRect(topcell, infoIn, 1000, phW.w, phW.layer, phW.dtype);
[topcell, infoOut] = PlaceArc(topcell, infoOut, 180, phW.r, phW.w, phW.layer, phW.dtype);
[topcell, infoOut] = PlaceRect(topcell, infoOut, 1000, phW.w, phW.layer, phW.dtype);

infoOut = MergeInfo(infoOut, InvertInfo(infoIn));

[topcell, infoOut] = PlaceArc(topcell, infoOut, 90, phW.r, phW.w, phW.layer, phW.dtype, 'group', true, 'distance', phW.sp);
[topcell, infoOut] = PlaceSBend(topcell, infoOut, 100, 0, phW.r, phW.w, phW.layer, phW.dtype, 'group', true, 'distance', fA.sp, 'align', 'bottom');
[topcell, infoOut] = PlaceRect(topcell, infoOut, fA.safety, phW.w, phW.layer, phW.dtype);
[topcell, infoOut] = PlaceRef(topcell, infoOut, refs(1).cellname);

infoIn = [];
infoOut = [];

% Line of code to add text in the gds
strel = gdsii_ptext('String test', [4000,50], 100, layerMap.FullCore, 0);
topcell = add_element(topcell, strel);

%% Save GDS and .mat cell information
FinalizeCell(cad, cellname, topcell, refs, infoIn, infoOut, log);

