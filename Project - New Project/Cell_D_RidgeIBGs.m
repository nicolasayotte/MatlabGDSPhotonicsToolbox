%% RidgeBraggGratings
% Author : Nicolas Ayotte
% Creation date : 01/04/2014

% The entire programs is in microns.


%% Initialize Cell Parameters
tp = cd; cd ..; addpath(genpath(cd)); cd(tp);     % add path to every folder of the library
[log, cad, cellname, topcell, layerMap] = InitializeCell();


%% Define Cell Objects
phW = Waveguide([0.5, 3.5], [layerMap.FullCore, layerMap.FullClad], 5, 3.5);
rdW = Waveguide([0.5, 3.5, 1, 3.5], [layerMap.FullCore, layerMap.FullClad, layerMap.MidCore, layerMap.MidClad], 5, 3.5);
shW = Waveguide([0.5, 3.5, 1, 3.5], [layerMap.FullCore, layerMap.FullClad, layerMap.ShallowCore, layerMap.ShallowClad], 5, 3.5);
fA = FiberArray(250, 30 * sqrt(3), 30, 55, 30, 20);

braggN = 4;
braggLen = 240;
braggCorrugation = zeros(braggN, 4);
braggCorrugation( : , 1) = linspace(0, 0.2, braggN);
braggCorrugation( : , 3) = linspace(1, 0, braggN);

braggRd = BraggFromParameters(braggLen, rdW.w, 0.28, braggCorrugation, 0.5, 1e-7, [], rdW.layer, rdW.dtype);
braggSh = BraggFromParameters(braggLen, shW.w, 0.28, braggCorrugation, 0.5, 1e-7, [], shW.layer, shW.dtype);
bragg = [braggRd; braggSh];

taperLen = 50;
taper = Taper(bragg, phW);


%% Load GDS Library References
refs = [];


%% Create the cell
% Initialize the cell inputs and outputs
infoIn = [];
infoOut = [];

% Get a cursor information
info = CursorInfo(cumsum(repmat([0, 2 * phW.r + phW.sp], 2 * braggN, 1), 1), 0, [1, 2.78]);
info.pos = RotTransXY(info.pos, [phW.r + 0.5 * phW.sp + taperLen, 0.5 * phW.sp - 2 * phW.r - phW.sp], 0);

strEl = arrayfun(@(x, y, len) gds_element('text', 'text', '(0, 0)', 'xy', [x, y], 'layer', layerMap.TXT(1)), info.pos( : , 1), info.pos( : , 2), 'UniformOutput', 0);
topcell = add_element(topcell, strEl');


[topcell, outInfo, info] = PlaceStructure(topcell, info, bragg);
[topcell, outInfo] = PlaceTaper(topcell, outInfo, taper, taperLen);

[topcell, info] = PlaceTaper(topcell, info, taper, taperLen);
[topcell, info] = PlaceArc(topcell, info, -180, phW.r, phW.w, phW.layer, phW.dtype);
[topcell, info] = PlaceRect(topcell, info, braggLen + 2 * taperLen, phW.w, phW.layer, phW.dtype);


infoIn = outInfo;
infoOut = info;

totalLengths = infoIn.length + infoOut.length;

strEl = arrayfun(@(x, y, len) gds_element('text', 'text', ['Length : ' num2str(len, '%01.1f')], 'xy', [x, y], 'layer', layerMap.TXT(1)), infoOut.pos( : , 1), infoOut.pos( : , 2), totalLengths( : , 1), 'UniformOutput', 0);
topcell = add_element(topcell, strEl');


%% Save GDS and .mat cell information
FinalizeCell(cad, cellname, topcell, refs, infoIn, infoOut, log);

