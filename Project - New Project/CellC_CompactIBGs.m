%% CompactBraggGratings
% Author : Nicolas Ayotte
% Creation date : 01/04/2014

% The entire programs is in microns.


%% Initialize Cell Parameters
tp = cd; cd ..; addpath(genpath(cd)); cd(tp);     % add path to every folder of the library
[log, cad, cellname, topcell, layerMap] = InitializeCell();


%% Define Cell Objects
phW = Waveguide([0.5, 3.5], [layerMap.FullCore, layerMap.FullClad], 5, 3.5);
fA = FiberArray(250, 30 * sqrt(3), 30, 55, 30, 20);

nBragg = 10;
lenBragg = 400;
bragg = BraggFromParameters(lenBragg, phW.w, linspace(0.22, 0.35, nBragg)', [0.1, 0], 0.5, 1e-7, [], phW.layer, phW.dtype);
if(mod(nBragg, 2))
   len = lenBragg + ceil(nBragg/2) * (2 * phW.r + phW.sp) - phW.r - 0.5 * phW.sp;
else
   len = lenBragg + floor(nBragg/2) * (2 * phW.r + phW.sp) + phW.r - 0.5 * phW.sp;
end
width =  2 * nBragg * phW.sp + 4 * phW.r;


%% Load GDS Library References
refs = [];


%% Create the cell
% Initialize the cell inputs and outputs
infoIn = [];  % inputs
infoOut = [];  % outputs

% Get a cursor information
info = CursorInfo(cumsum(repmat([0, phW.sp * 2], nBragg, 1), 1), 0, [1, 2.78]);
info.pos = RotTransXY(info.pos, [len - lenBragg, 2 * phW.r - 1.5 * phW.sp], 0);

strEl = arrayfun(@(x, y, len) gds_element('text', 'text', '(0, 0)', 'xy', [x, y], 'layer', layerMap.TXT(1)), info.pos( : , 1), info.pos( : , 2), 'UniformOutput', 0);
topcell = add_element(topcell, strEl');

[topcell, info, tInput] = PlaceStructure(topcell, info, bragg);

lenBottom = cumsum(repmat(2 * phW.r + phW.sp, floor(nBragg/2), 1)) - (2 * phW.r + phW.sp);
bottomInfo = SplitInfo(tInput, 1 : floor(nBragg/2));
[topcell, bottomInfo] = PlaceRect(topcell, bottomInfo, lenBottom, phW.w, phW.layer, phW.dtype);
[topcell, bottomInfo] = PlaceArc(topcell, bottomInfo, 90, phW.r, phW.w, phW.layer, phW.dtype);
[topcell, bottomInfo] = PlaceArc(topcell, bottomInfo, -180, phW.r, phW.w, phW.layer, phW.dtype);
[topcell, bottomInfo] = PlaceRect(topcell, bottomInfo, phW.sp, phW.w, phW.layer, phW.dtype);
[topcell, bottomInfo] = PlaceArc(topcell, bottomInfo, -90, phW.r, phW.w, phW.layer, phW.dtype);
[topcell, bottomInfo] = PlaceRect(topcell, bottomInfo, lenBragg + lenBottom + 2 * phW.r, phW.w, phW.layer, phW.dtype);

lenTop = flipud(cumsum(repmat(2 * phW.r + phW.sp, nBragg - floor(nBragg/2), 1))) - phW.sp;
topInfo = SplitInfo(tInput, 1 + floor(nBragg/2) : nBragg);
[topcell, topInfo] = PlaceRect(topcell, topInfo, lenTop, phW.w, phW.layer, phW.dtype);
[topcell, topInfo] = PlaceArc(topcell, topInfo, -90, phW.r, phW.w, phW.layer, phW.dtype);
[topcell, topInfo] = PlaceRect(topcell, topInfo, phW.sp, phW.w, phW.layer, phW.dtype);
[topcell, topInfo] = PlaceArc(topcell, topInfo, -180, phW.r, phW.w, phW.layer, phW.dtype);
[topcell, topInfo] = PlaceArc(topcell, topInfo, 90, phW.r, phW.w, phW.layer, phW.dtype);
[topcell, topInfo] = PlaceRect(topcell, topInfo, lenBragg + lenTop - 2 * phW.r, phW.w, phW.layer, phW.dtype);

infoIn = info;
infoOut = MergeInfo(topInfo, bottomInfo);


totalLengths = infoIn.length + infoOut.length;
strEl = arrayfun(@(x, y, len) gds_element('text', 'text', ['Length : ' num2str(len, '%01.1f')], 'xy', [x, y], 'layer', layerMap.TXT(1)), infoOut.pos( : , 1), infoOut.pos( : , 2), totalLengths( : , 1), 'UniformOutput', 0);
topcell = add_element(topcell, strEl');


%% Save GDS and .mat cell information
FinalizeCell(cad, cellname, topcell, refs, infoIn, infoOut, log);

