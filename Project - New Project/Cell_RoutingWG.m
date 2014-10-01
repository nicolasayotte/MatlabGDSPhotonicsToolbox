%% RoutingWaveguides
% Author : Nicolas Ayotte
% Creation date : 01/04/2014

% The entire programs is in microns.


%% Initialize Cell Parameters
tp = cd; cd ..; addpath(genpath(cd)); cd(tp);     % add path to every folder of the library
[log, cad, cellname, topcell, layerMap] = InitializeCell();
delete('Cells/ * _put.mat');


%% Load GDS Library References
refs(1).filename = '../Library/GratingCouplerDummy.gds';
refs(1).cellname = 'GratingCouplerDummy';
refs = GetRefsFloorplan(refs);


%% Define general structures
phW = Waveguide([0.5, 3.5], [layerMap.FullCore, layerMap.FullClad], 5, 3.5);
fA = FiberArray(90, 30 * sqrt(3), 30, ceil(refs(1).floorplan.size(1)/5) * 5, ceil(refs(1).floorplan.size(2)/5) * 5, 20);


%% Load the cell floorplan and positioning information
cellInfo = GetCellInfo(cad);

% Topcell Space
floorplanElement = gds_element('boundary', 'xy', MakeRect([0, 0], cad.size), 'layer', layerMap.FP(1), 'dtype', layerMap.FP(2));
topcell = add_element(topcell, floorplanElement);

% Margin Space
limitPoly = MakeRect([cad.margin.left, cad.margin.bottom], cad.size - [cad.margin.left + cad.margin.right, cad.margin.bottom + cad.margin.top]);
marginElement = gds_element('boundary', 'xy', limitPoly, 'layer', layerMap.FP(1), 'dtype', layerMap.FP(2));
topcell = add_element(topcell, marginElement);


%% Placing cells A and B
% Put Cell_A_StraightWG
[topcell, cellInfo] = PutCell(topcell, cad, cellInfo, layerMap, ...
   'Cell_A_StraightWG', 'anchor', 'floorplan', 'verticalAlign', 'bottomInside', ...
   'horizontalAlign', 'leftInside');

% Put Cell_B_Microrings
[topcell, cellInfo, infoIn, infoOut] = PutCell(topcell, cad, cellInfo, layerMap, ...
   'Cell_B_Microrings', 'anchor', 'Cell_A_StraightWG', 'verticalAlign', 'topOutside', ...
   'horizontalAlign', 'leftInside', 'offset', [0, 0], 'strans', struct('angle', 180, 'reflect', 1));
infoB = MergeInfo(infoIn, infoOut);
[topcell, ~, ~, arraySize] = PlaceCouplerArray(topcell, infoB, 4, phW, fA, refs(1).cellname, layerMap, 'type', 'cladding', 'direction', -1, 'text', 'strWg_coupler_', 'textIndex', 2);


%% Placing cells C, D and E
% Put Cell_E_CustomIBGs
% Anchoring using different vertical and horizontal anchors
[topcell, cellInfo, infoIn, infoOut, cellERect] = PutCell(topcell, cad, cellInfo, layerMap, ...
   'Cell_E_CustomIBGs', 'anchorVertical', 'Cell_B_Microrings', 'verticalAlign', 'topOutside', ...
   'anchorHorizontal', 'Cell_A_StraightWG', 'horizontalAlign', 'leftInside', ...
   'offset', [arraySize(2) + phW.r + 2.5 * phW.sp, 0], 'strans', struct('angle', 180, 'reflect', 0));
[topcell, infoOut] = PlaceArc(topcell, infoOut, -180, phW.r, phW.w, phW.layer, phW.dtype, 'group', true, 'distance', phW.sp);
[topcell, infoOut] = PlaceRect(topcell, infoOut, abs(cellERect(1, 1) - cellERect(3, 1)), phW.w, phW.layer, phW.dtype);
infoE = MergeInfo(infoIn, infoOut);
[topcell, infoE] = PlaceSBend(topcell, infoE, 100, -0.75, phW.r, phW.w, phW.layer, phW.dtype, 'group', true, 'distance', phW.sp, 'align', 'bottom');

% Put Cell_C_CompactIBGs
[topcell, cellInfo, infoIn, infoOut] = PutCell(topcell, cad, cellInfo, layerMap, ...
   'Cell_C_CompactIBGs', 'anchor', 'floorplan', 'verticalAlign', 'topInside', ...
   'horizontalAlign', 'leftInside', 'offset', [0, 0], 'strans', struct('angle', -90, 'reflect', 0));
infoC1 = MergeInfo(infoIn, infoOut);

% Put Cell_C_CompactIBGs for a second time (index 2)
[topcell, cellInfo, infoIn, infoOut, cellCRect] = PutCell(topcell, cad, cellInfo, layerMap, ...
   'Cell_C_CompactIBGs', 'anchor', 'Cell_C_CompactIBGs', 'verticalAlign', 'topInside', ...
   'horizontalAlign', 'rightOutside', 'offset', [0, 0], 'strans', struct('angle', -90, 'reflect', 0));
infoC2 = MergeInfo(infoIn, infoOut);
infoC = MergeInfo(infoC1, infoC2);

% Put Cell_D_RidgeIBGs
% Anchoring to the second placement of Cell_C_CompactIBGs using 'anchorIndex', 2
[topcell, cellInfo, infoIn, infoOut, cellDRect] = PutCell(topcell, cad, cellInfo, layerMap, ...
   'Cell_D_RidgeIBGs', 'anchor', 'Cell_C_CompactIBGs', 'verticalAlign', 'topInside', ...
   'horizontalAlign', 'rightOutside', 'offset', [0, 0], 'strans', struct('angle', -90, 'reflect', 0), ...
   'anchorIndex', 2);
infoD = MergeInfo(infoIn, infoOut);

cellCHeight = abs(cellCRect(1, 2) - cellCRect(3, 2));
cellDHeight = abs(cellDRect(1, 2) - cellDRect(3, 2));

[topcell, infoD] = PlaceRect(topcell, infoD, 46.5 + cellCHeight - cellDHeight - phW.sp * size(infoD.pos, 1), phW.w, phW.layer, phW.dtype);
[topcell, infoD] = PlaceArc(topcell, infoD, 90, phW.r, phW.w, phW.layer, phW.dtype, 'group', true, 'distance', phW.sp);

[topcell, infoC] = PlaceRect(topcell, infoC, 46.5, phW.w, phW.layer, phW.dtype);
[topcell, infoC] = PlaceArc(topcell, infoC, 90, phW.r, phW.w, phW.layer, phW.dtype, 'group', true, 'distance', phW.sp);
[topcell, infoC] = PlaceRect(topcell, infoC, abs(infoC.pos(1, 1) - infoD.pos(1, 1)), phW.w, phW.layer, phW.dtype);

[topcell, infoCOut, ~, arraySize] = PlaceCouplerArray(topcell, MergeInfo(infoC, infoD), 2, phW, fA, refs(1).cellname, layerMap, 'type', 'cladding');

indicesOut = [1 : 10, 21 : 30, 41 : 48];
indicesIn = [11 : 20, 31 : 40, 49 : 56];
totalLengths = infoCOut.length(indicesOut, 1) + infoCOut.length(indicesIn, 1);

strEl = arrayfun(@(x, y, len) gds_element('text', 'text', ['Length : ' num2str(len, '%01.1f')], 'xy', [x, y], 'layer', layerMap.TXT(1)), infoCOut.pos( indicesOut , 1), infoCOut.pos( indicesOut , 2), totalLengths( : , 1), 'UniformOutput', 0);
topcell = add_element(topcell, strEl');

% Put Cell_C_CompactIBGs for a second time (index 2)
[topcell, cellInfo, infoIn, infoOut, cellCRect] = PutCell(topcell, cad, cellInfo, layerMap, ...
   'Cell_F_MZI', 'anchor', 'Cell_A_StraightWG', 'verticalAlign', 'bottomInside', ...
   'horizontalAlign', 'rightOutside', 'offset', [50, 0], 'strans', struct('angle', -90, 'reflect', 0));


%% Save .gsd and .mat cell information
% Put Cell_RoutingWG and Finalize cell
[topcell, cellInfo] = PutCell(topcell, cad, cellInfo, layerMap, ...
   'Cell_RoutingWG', 'anchor', 'absolute', 'offset', [0, 0]);

infoIn = [];      infoOut = [];
FinalizeCell(cad, cellname, topcell, refs, infoIn, infoOut, log);

