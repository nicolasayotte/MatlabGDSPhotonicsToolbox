%% CompactBraggGratings
% Author : Nicolas Ayotte                                  Creation date : 01/04/2014
% 
% The entire programs is in microns.


%% Initialize Cell Parameters
tp = cd; cd ../Functions/; addpath(genpath(cd)); cd(tp);     % add path to every folder of the library
[log, cad, cellname, topcell, layerMap] = InitializeCell();


%% Define Cell Objects
phW = Waveguide([0.5, 3.5], [layerMap.FullCore, layerMap.FullClad], 5, 3.5);

nBragg = 20;
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
refs = GetRefsFloorplan(refs);


%% Create the cell
info = CursorInfo(cumsum(repmat([0, phW.sp * 2], nBragg, 1), 1), 0, [1, 2.78]);
info.pos = RotTransXY(info.pos, [len - lenBragg, 2 * phW.r - 1.5 * phW.sp], 0);


% Write text at the initial cursor positions
strEl = arrayfun(@(x, y, len) gds_element('text', 'text', 'Initial info position',...
   'xy', [x, y], 'layer', layerMap.TXT(1)), info.pos( : , 1), info.pos( : , 2), 'UniformOutput', 0);
topcell = add_element(topcell, strEl');


% Place the bragg gratings
[topcell, info, infoIn] = PlaceStructure(topcell, info, bragg);
[topcell, info] = PlaceCompactUTurn(topcell, info, phW);
[topcell, infoOut] = PlaceRect(topcell, info, lenBragg, phW.w, phW.layer, phW.dtype);


% Write the total length information
totalLengths = infoIn.length + infoOut.length;
strEl = arrayfun(@(x, y, len) gds_element('text', 'text', ['Length : ' num2str(len, '%01.1f')], ...
   'xy', [x, y], 'layer', layerMap.TXT(1)), infoOut.pos( : , 1), infoOut.pos( : , 2), totalLengths( : , 1), 'UniformOutput', 0);
topcell = add_element(topcell, strEl');


%% Save GDS and .mat cell information
FinalizeCell(cad, cellname, topcell, refs, infoIn, infoOut, log);

