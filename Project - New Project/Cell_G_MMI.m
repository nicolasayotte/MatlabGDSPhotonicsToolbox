%%Cell_G_MMI_CDC
%Author : Nicolas Ayotte                                   Creation date : 25/11/2014
% 
% The entire programs is in microns.


%% Initialize Cell Parameters
tp = cd; cd ../Functions/; addpath(genpath(cd)); cd(tp);     % add path to every folder of the library
[log, cad, cellname, topcell, layerMap] = InitializeCell();


%% Load GDS Library References
refs = [];
refs = GetRefsFloorplan(refs);


%% Define Objects
phW = Waveguide([0.5, 3.5], [layerMap.FullCore, layerMap.FullClad], 5, 3.5);
phW2 = Waveguide([0.5, 3.5], [layerMap.FullCore, layerMap.FullClad], 5, 3.5);
mmi = MMI(30 + [0, 3], 200, 50, 0.5, phW.layer, phW.dtype);

bragg1 = BraggFromParameters(100, phW.w, 0.280, [0.1, 0], 0.5, 0, [], phW.layer, phW.dtype);
bragg2 = BraggFromParameters(100, phW.w, 0.300, [0.1, 0], 0.5, 0, [], phW.layer, phW.dtype);


%% Create Multi-mode Interferometer
waveguideCount = 1;
posy = phW.sp * (0 : waveguideCount - 1)';
posx = 0 * posy;
info = CursorInfo([posx, posy], 0, 1);

infoIn = InvertInfo(info);

[topcell, info] = PlaceMMI(topcell, info, phW, phW2, mmi, 'nout', 2);
[topcell, info] = PlaceArc(topcell, info, 90, phW.r, phW.w, phW.layer, phW.dtype, 'group', true);
[topcell, info] = PlaceRect(topcell, info, 50, phW.w, phW.layer, phW.dtype);
[topcell, info] = PlaceArc(topcell, info, 90, phW.r, phW.w, phW.layer, phW.dtype, 'group', true);

mmi.len = mmi.len / 4;
[topcell, info] = PlaceMMI(topcell, info, phW, phW2, mmi);


%% Create a Contra-direction Coupler
[topcell, info] = PlaceArc(topcell, info, -90, phW.r, phW.w, phW.layer, phW.dtype, 'group', true);
[topcell, info] = PlaceRect(topcell, info, 50, phW.w, phW.layer, phW.dtype);
[topcell, info] = PlaceArc(topcell, info, -90, phW.r, phW.w, phW.layer, phW.dtype, 'group', true);
[topcell] = PlaceCDC(topcell, SplitInfo(info, 1), phW, bragg1, bragg2, 0.5, 0);

infoOut = [];


%% Save GDS and .mat cell information
FinalizeCell(cad, cellname, topcell, refs, infoIn, infoOut, log);