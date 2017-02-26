%%Cell_H_aref_internalRef
%Author : Nicolas Ayotte                                   Creation date : 25/11/2014
% 
% The entire programs is in microns.


%% Initialize Cell Parameters
tp = cd; cd ../Functions/; addpath(genpath(cd)); cd(tp);     % add path to every folder of the library
[log, cad, cellname, topcell, layerMap] = InitializeCell();


%% Load GDS Library References
refs(1).filename = '../Library/GratingCouplerDummy.gds';
refs(1).cellname = 'GratingCouplerDummy';
refs = GetRefsFloorplan(refs);


%% Define Objects
phW = Waveguide([0.5, 3.5], [layerMap.FullCore, layerMap.FullClad], 5, 3.5);


%% ARef example
waveguideCount = 1;
posy = phW.sp * (0 : waveguideCount - 1)';
posx = 0 * posy;
info = CursorInfo([posx, posy], 0, 1);

[topcell, info] = PlaceArc(topcell, info, -90, phW.r, phW.w, phW.layer, phW.dtype, 'group', true);
[topcell, info] = PlaceArc(topcell, info, 90, phW.r, phW.w, phW.layer, phW.dtype, 'group', true);
[topcell] = PlaceARef(topcell, SplitInfo(info, 1), refs(1).cellname, 0:2, -3:3, [50, 40]);


%% Creating an internal reference
internalRef = gds_structure('internalRef');
waveguideCount = 1;
posy = phW.sp * (0 : waveguideCount - 1)';
posx = 0 * posy;
infoRel = CursorInfo([posx, posy], 0, 1);

[internalRef, infoRel] = PlaceRect(internalRef, infoRel, 10, phW.w, phW.layer, phW.dtype);
[internalRef, infoRel] = PlaceArc(internalRef, infoRel, 270, phW.r, phW.w, phW.layer, phW.dtype);
[internalRef, infoRel] = PlaceRect(internalRef, infoRel, 10, phW.w, phW.layer, phW.dtype);
[internalRef, infoRel] = PlaceArc(internalRef, infoRel, -270, phW.r, phW.w, phW.layer, phW.dtype);


%% Using an internal reference is as easy as using its name
% That cell name must be UNIQUE in all the project
waveguideCount = 1;
posy = phW.sp * (0 : waveguideCount - 1)' + 115;
posx = 0 * posy + 240;
info = CursorInfo([posx, posy], 0, 1);
[topcell, info] = PlaceArc(topcell, info, -90, phW.r, phW.w, phW.layer, phW.dtype);
[topcell, info] = PlaceRect(topcell, info, 90, phW.w, phW.layer, phW.dtype);
[topcell] = PlaceARef(topcell, SplitInfo(info, 1), 'internalRef', 0:3, -1:3, [30, 20]);
[topcell, info] = PlaceRect(topcell, info, 150, phW.w, phW.layer, phW.dtype);
[topcell] = PlaceARef(topcell, SplitInfo(info, 1), 'internalRef', 0:1, -2.5:2.5, [35, 20], 'ang', -45);

infoIn = [];
infoOut = [];


%% Save GDS and .mat cell information

GDSinCell;
FinalizeCell(cad, cellname, cells, refs, infoIn, infoOut, log);