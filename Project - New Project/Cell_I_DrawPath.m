%%CELL_I_DRAW_PATH
% Author: ADS                                  Creation date : 22/09/2015
% The entire programs is in microns.


%% Initialize Cell Parameters
tp = cd; cd ../Functions/; addpath(genpath(cd)); cd(tp);     % add path to every folder of the library
[log, cad, cellname, topcell, layerMap] = InitializeCell();


%% Load GDS Library References
refs(1).filename = '../Library/GratingCouplerDummy.gds';
refs(1).cellname = 'GratingCouplerDummy';
refs = GetRefsFloorplan(refs);


%% Define Objects
InputSpacing = 500;
WGrouting = Waveguide([0.5, 5], [layerMap.FullCore, layerMap.FullClad], 15, 5);
Zspiral = PathSpiral([10,20], [50,100], 0.6, 10, 'display', false, 'figure', false);
%% Create the cells
info = CursorInfo([-10,0], 50, [1,2]);
info =  CloneInfo(info, 2, 0, InputSpacing, 0);
infoIn = InvertInfo(info);


%% Main paths
[topcell, info, infoInput] = PlaceRect(topcell, info, 10, WGrouting.w, WGrouting.layer, WGrouting.dtype);
[topcell, info] = PlacePath(topcell, info, Zspiral, WGrouting);
[topcell, info] = PlaceRect(topcell, info, 20, WGrouting.w, WGrouting.layer, WGrouting.dtype);


%%  Arranging the inputs and outputs for exports
infoOut = info;


%% Save GDS and .mat cell information
FinalizeCell(cad, cellname, topcell, refs, infoIn, infoOut, log);

