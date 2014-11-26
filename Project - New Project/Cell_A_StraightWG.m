%%CELL_A_STRAIGHTWG
% Author : Nicolas Ayotte                                  Creation date : 22/11/2014
% The entire programs is in microns.


%% Initialize Cell Parameters
tp = cd; cd ../Functions/; addpath(genpath(cd)); cd(tp);     % add path to every folder of the library
[log, cad, cellname, topcell, layerMap] = InitializeCell();


%% Load GDS Library References
refs = [];
refs = GetRefsFloorplan(refs);


%% Define Objects
% Creates waveguide objects and a taper from one waveguide to another
phW = Waveguide([0.5, 3.5], [layerMap.FullCore, layerMap.FullClad], 5, 3.5);
phW2 = Waveguide([5.5, 8.5], [layerMap.FullCore, layerMap.FullClad], 15, 8.5);
taper = Taper(phW, phW2);


%% Create the cell
waveguideCount = 16;
posy = 2 * phW.sp * (0 : waveguideCount - 1)';
posx = 0 * posy;
info = CursorInfo([posx, posy], 0, 1);


% Places the initial waveguides with a u-turn
[topcell, info, infoIn] = PlaceRect(topcell, info, 100, phW.w, phW.layer, phW.dtype);
[topcell, info] = PlaceCompactUTurn(topcell, info, phW);
[topcell, info] = PlaceRect(topcell, info, 100, phW.w, phW.layer, phW.dtype);


% This combines the outputs and inputs so that they can be routed together
info = MergeInfo(info, infoIn);


% 'distance' makes it possible to ajust inter-waveguide distance in s-bends (and arcs)
[topcell, info] = PlaceSBend(topcell, info, 150, 0, phW.r, phW.w, phW.layer, phW.dtype,...
   'group', true, 'distance', 2 * phW.sp, 'backgroundRect', true);


% 'equidistant' maintains the inter-waveguide distance constant during a turn. This
% is incompatible with the PlaceArc 'distance' option
[topcell, info] = PlaceArc(topcell, info, -90, phW.r, phW.w, phW.layer, phW.dtype,...
   'group', true, 'type', 'equidistant', 'resolution', 300e-3);


% 'minimumLength' ensures that the S-Bend is as compact as possible
[topcell, info] = PlaceSBend(topcell, info, 0, -1.5, phW.r, phW.w, phW.layer, phW.dtype,...
   'group', true, 'distance', phW.sp, 'minimumLength', true, 'align', 'center', 'backgroundRect', true);
[topcell, info] = PlaceRect(topcell, info, phW.sp * ceil(20 * abs(rand(waveguideCount * 2, 1))), phW.w, phW.layer, phW.dtype);


% The 'type', 'movement' option is useful for moving your cursors as if placing a
% rectangle or arc. It does not place polygons or increment the 'length' of cursors.
% You will see holes in the resulting waveguides
[topcell, info] = PlaceRect(topcell, info, 2, phW.w, phW.layer, phW.dtype, 'type', 'movement');


% The 'align' true option adjust the lengths of parallel waveguides so that they are
% aligned together THEN goes forward the indicated length (i.e.: 10 um)
[topcell, info] = PlaceRect(topcell, info, 10, phW.w, phW.layer, phW.dtype, 'group', true, 'align', true);


% This is just a simple show of different features
cutoutAngle = 10;
[topcell, info] = PlaceSBend(topcell, info, 0, 0, phW.r, phW.w, phW.layer, phW.dtype,...
   'group', true, 'distance', phW2.sp, 'minimumLength', true, 'align', 'center', 'backgroundRect', true);
[topcell, info] = PlaceTaper(topcell, info, taper, 100);
[topcell, info] = PlaceArc(topcell, info, -(90 - cutoutAngle/2), phW2.r, phW2.w, phW2.layer, phW2.dtype, 'group', true);
[topcell, info] = PlaceArc(topcell, info, -cutoutAngle, phW2.r, phW2.w, phW2.layer, phW2.dtype, 'group', true, 'type', 'movement');
[topcell, info] = PlaceArc(topcell, info, -(90 - cutoutAngle/2), phW2.r, phW2.w, phW2.layer, phW2.dtype, 'group', true);
[topcell, info] = PlaceTaper(topcell, info, taper, 100, 'invert', true);
[topcell, info] = PlaceArc(topcell, info, 90, phW.r, phW.w, phW.layer, phW.dtype, 'group', true, 'distance', phW.sp);
[topcell, info] = PlaceRect(topcell, info, 60, phW.w, phW.layer, phW.dtype);


%  Arranging the inputs and outputs for exports
infoIn = SplitInfo(info, 1:length(info.ori)/2);
infoOut = SplitInfo(info, length(info.ori)/2 + (1:length(info.ori)/2));


%% Save GDS and .mat cell information
FinalizeCell(cad, cellname, topcell, refs, infoIn, infoOut, log);

