%% RoutingWaveguides
% Author : Nicolas Ayotte
% Creation date : 01/04/2014

% The entire programs is in microns.


%% Initialize Cell Parameters
tp = cd; cd ../Functions/; addpath(genpath(cd)); cd(tp);     % add path to every folder of the library
[log, cad, cellname, topcell, layerMap] = InitializeCell();
delete('Cells/*_put.mat');


%% Load GDS Library References
refs(1).filename = '../Library/GratingCouplerDummy.gds';
refs(1).cellname = 'GratingCouplerDummy';
refs = GetRefsFloorplan(refs);


%% Define general structures
phW = Waveguide([0.5, 3.5], [layerMap.FullCore, layerMap.FullClad], 5, 3.5);
fA = FiberArray(200, 30 * sqrt(3), 30, ceil(refs(1).floorplan.size(1)/5) * 5, ceil(refs(1).floorplan.size(2)/5) * 5, 20);


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
[topcell, cellInfo, infoIn, infoOut] = PutCell(topcell, cad, cellInfo, layerMap, log, ...
   'Cell_A_StraightWG', 'anchor', 'floorplan', 'verticalAlign', 'bottomInside', ...
   'horizontalAlign', 'leftInside');
infoA = MergeInfo(infoIn, infoOut);
[topcell, ~, ~, arraySize] = PlaceCouplerArray(topcell, infoA, 2, phW, fA, refs(1).cellname, layerMap, 'type', 'cladding', 'direction', 1);


% Put Cell_B_Microrings
[topcell, cellInfo, infoIn, infoOut] = PutCell(topcell, cad, cellInfo, layerMap, log, ...
   'Cell_B_Microrings', 'anchor', 'Cell_A_StraightWG', 'verticalAlign', 'bottomInside', ...
   'horizontalAlign', 'rightInside', 'strans', struct('angle', -90, 'reflect', 0), 'offset', [arraySize(1), 0]);
infoB = MergeInfo(infoIn, infoOut);
text123 = arrayfun(@(x) ['Square root index ' num2str(x, '%1.8f')], (1:7).^0.5, 'UniformOutput', false);
[topcell, ~, ~, arraySize] = PlaceCouplerArray(topcell, infoB, 4, phW, fA, refs(1).cellname, layerMap, 'type', 'cladding', 'direction', 1, 'text', text123, 'textIndex', 2);


%% Cells C and D
% Put Cell_C_CompactIBGs
[topcell, cellInfo, infoIn, infoOut] = PutCell(topcell, cad, cellInfo, layerMap, log, ...
   'Cell_C_CompactIBGs', 'anchor', 'Cell_A_StraightWG', 'verticalAlign', 'topOutside', ...
   'horizontalAlign', 'leftInside', 'offset', [0, 5], 'strans', struct('angle', -90, 'reflect', 0));
infoC1 = MergeInfo(infoIn, infoOut);
numC = size(infoC1.pos, 1);

% Put Cell_C_CompactIBGs for a second time (index 2)
[topcell, cellInfo, infoIn, infoOut,] = PutCell(topcell, cad, cellInfo, layerMap, log, ...
   'Cell_C_CompactIBGs', 'anchor', 'Cell_C_CompactIBGs', 'verticalAlign', 'bottomInside', ...
   'horizontalAlign', 'rightOutside', 'strans', struct('angle', -90, 'reflect', 0));
infoC2 = MergeInfo(infoIn, infoOut);
infoC = MergeInfo(infoC1, infoC2);


% Put Cell_D_RidgeIBGs
% Anchoring to the second placement of Cell_C_CompactIBGs using 'anchorIndex', 2
[topcell, cellInfo, infoIn, infoOut] = PutCell(topcell, cad, cellInfo, layerMap, log, ...
   'Cell_D_RidgeIBGs', 'anchor', 'Cell_C_CompactIBGs', 'verticalAlign', 'bottomInside', ...
   'horizontalAlign', 'rightOutside', 'strans', struct('angle', -90, 'reflect', 0), ...
   'anchorIndex', 2);
infoD = MergeInfo(infoIn, infoOut);
numD = size(infoD.pos, 1);
infoCD = MergeInfo(infoC, infoD);


[topcell, infoCD] = PlaceRect(topcell, infoCD, 0, phW.w, phW.layer, phW.dtype,...
   'group', true, 'align', true);
[topcell, infoCD] = PlaceArc(topcell, infoCD, -90, phW.r, phW.w, phW.layer, phW.dtype,...
   'group', true, 'distance', phW.sp);
[topcell, infoCD, infoTest, arraySize] = PlaceCouplerArray(topcell, infoCD, 2, phW, fA, ...
   refs(1).cellname, layerMap, 'type', 'cladding', 'direction', -1);


indicesIn = [(1:numC/2), (1:numC/2) + numC, (1:numD/2) + 2 * numC];
indicesOut = [(1:numC/2) + numC/2, (1:numC/2) + 1.5 * numC, (1:numD/2) + 2 * numC + numD/2];
totalLengths = infoCD.length(indicesOut, 1) + infoCD.length(indicesIn, 1);
strEl = arrayfun(@(x, y, len) gds_element('text', 'text', ['Length : ' num2str(len, '%01.1f')],...
   'xy', [x, y], 'layer', layerMap.TXT(1)), infoCD.pos( indicesOut , 1), infoCD.pos( indicesOut , 2),...
   totalLengths( : , 1), 'UniformOutput', 0);
topcell = add_element(topcell, strEl');


%% Put Cell E and F
% Put Cell_E_CustomIBGs
[topcell, cellInfo] = PutCell(topcell, cad, cellInfo, layerMap, log, ...
   'Cell_E_CustomIBGs', 'anchor', 'floorplan', 'verticalAlign', 'topInside', ...
   'horizontalAlign', 'leftInside');


% Put Cell_F_MZI
[topcell, cellInfo] = PutCell(topcell, cad, cellInfo, layerMap, log, ...
   'Cell_F_MZI', 'anchor', 'Cell_E_CustomIBGs', 'verticalAlign', 'bottomOutside', ...
   'horizontalAlign', 'leftInside');


% Put Cell_G_MMI
[topcell, cellInfo] = PutCell(topcell, cad, cellInfo, layerMap, log, ...
   'Cell_G_MMI', 'anchorVertical', 'floorplan', 'verticalAlign', 'center', ...
   'anchorHorizontal', 'Cell_D_RidgeIBGs', 'horizontalAlign', 'rightOutside', 'offset', [arraySize(1), 0],...
   'strans', struct('angle', 90, 'reflect', 0));


% Put Cell_H_Aref_internalRef
[topcell, cellInfo] = PutCell(topcell, cad, cellInfo, layerMap, log, ...
   'Cell_H_Aref_internalRef', 'anchor', 'Cell_G_MMI', 'verticalAlign', 'center', ...
   'horizontalAlign', 'rightOutside');


%% Save .gsd and .mat cell information
% Put Cell_RoutingWG and Finalize cell
[topcell, cellInfo] = PutCell(topcell, cad, cellInfo, layerMap, log, ...
   'Cell_RoutingWG', 'anchor', 'absolute', 'offset', [0, 0]);

infoIn = [];      infoOut = [];
FinalizeCell(cad, cellname, topcell, refs, infoIn, infoOut, log);

