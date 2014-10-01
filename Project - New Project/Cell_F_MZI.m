%% MZI
% Author : Alexandre D. Simard
% Creation date : 06/19/2014
% The entire programs is in microns.


%% Initialize Cell Parameters
tp = cd; cd ..; addpath(genpath(cd)); cd(tp);     % add path to every folder of the library
[log, cad, cellname, topcell, layerMap] = InitializeCell();


%% Load GDS Library References
refs(1).filename = '../Library/GratingCouplerDummy.gds';
refs(1).cellname = 'GratingCouplerDummy';

refs(2).filename = '../Library/Ybranch.gds';
refs(2).cellname = 'Ybranch';
refs(2).dy = 5.7;

refs = GetRefsFloorplan(refs);

%% Define Cellref Objects
phW = Waveguide([0.5, 3.5], [layerMap.FullCore, layerMap.FullClad], 5, 5);
phW2 = Waveguide([0.5, 3.5], [layerMap.FullCore, layerMap.FullClad], 5, 5);
fA = FiberArray(250, 30 * sqrt(3), 30, ceil(refs(1).floorplan.size(1)/5) * 5, ceil(refs(1).floorplan.size(2)/5) * 5, 20);

MMIinfo = MMI([8,10], 242.8, 100, 0.9,  phW.layer,  phW.dtype);
rings = Microring(0.2, phW.layer, phW.dtype, 'radius', 10, 'w', phW.w,'gap',0.5);

%% Initialize the cell inputs and outputs

% Get a cursor information

infoOut = CursorInfo([0, 0], 0, 1);

[topcell, infoIn] = PlaceRect(topcell, InvertInfo(infoOut), fA.safety, phW.w, phW.layer, phW.dtype);
[topcell, infoIn] = PlaceRef(topcell, infoIn, refs(1).cellname); % input coupler

[topcell,infobranch1,infobranch2,ybranchinfo] = PlaceYbranch(topcell, infoOut, 1, refs(2).dy, refs(2).cellname, refs(2).filename); % input coupler

[topcell, infobranch1] = PlaceRect(topcell, infobranch1, 100, phW.w, phW.layer, phW.dtype);
[topcell, infobranch1] = PlaceMicroring(topcell, infobranch1, rings, phW.w, phW.layer, phW.dtype);
[topcell, infobranch1] = PlaceRect(topcell, infobranch1, 100, phW.w, phW.layer, phW.dtype);
[topcell, infobranch2] = PlaceRect(topcell, infobranch2, 200, phW.w, phW.layer, phW.dtype);

[topcell, infotr, inforef]= PlaceMMI(topcell, MergeInfo(infobranch1,infobranch2), phW, phW2, MMIinfo);


[topcell, infoOut] = PlaceRect(topcell, SplitInfo(infotr,1), 100, phW.w, phW.layer, phW.dtype);
[topcell, infoOut] = PlaceRef(topcell, infoOut, refs(1).cellname); % input coupler

infoIn = [];  % inputs % No external routing
infoOut = [];  % outputs % No external routing


%% Save GDS and .mat cell information
FinalizeCell(cad, cellname, topcell, refs, infoIn, infoOut, log);

