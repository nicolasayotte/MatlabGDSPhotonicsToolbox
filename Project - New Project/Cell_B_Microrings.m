%% Microring
% Author : Nicolas                                         Creation date : 13/05/2014
% The entire programs is in microns.


%% Initialize Cell Parameters
tp = cd; cd ../Functions/; addpath(genpath(cd)); cd(tp);     % add path to every folder of the library
[log, cad, cellname, topcell, layerMap] = InitializeCell();


%% Load GDS Library References
refs = [];
refs = GetRefsFloorplan(refs);


%% Define Cell Objects
phW = Waveguide([0.5, 3.5], [layerMap.FullCore, layerMap.FullClad], 5, 3.5);
ringNum = 14;
rings = Microring(0.2, phW.layer, phW.dtype, 'radius', linspace(0.25, 20, ringNum)', ...
   'w', phW.w, 'resolution', 100e-3, 'straightLength', linspace(0, 20, ringNum)');


%% Create the cell
posy = [0; cumsum(2 * (vertcat(rings(1 : end-1).radius) + vertcat(rings(1 : end-1).gap)) + 2 * phW.sp + 2 * phW.r + 2 * phW.w(1))];
posx = 0 * posy;
info = CursorInfo([posx, posy], 0, 1);


% Text (0, 0) at the origin of info
strEl = arrayfun(@(x, y, len) gds_element('text', 'text', '(0, 0)', 'xy', [x, y], 'layer', layerMap.TXT(1)), info.pos( : , 1), info.pos( : , 2), 'UniformOutput', 0);
topcell = add_element(topcell, strEl');


% Place the microrings
[topcell, infoThru, infoInput, infoContra, infoCross] = PlaceMicroring(topcell, info, rings, phW.w, phW.layer, phW.dtype);


% Cell routing
infoIn = struct();
for ring = 1 : ringNum
   tInfoIn = MergeInfo( SplitInfo(infoInput, ring), SplitInfo(infoContra, ring));
   [topcell, tInfoIn] = PlaceRect(topcell, tInfoIn, rings(ring).radius, phW.w, phW.layer, phW.dtype);
   [topcell, tInfoIn] = PlaceArc(topcell, tInfoIn, -180, phW.r, phW.w, phW.layer, phW.dtype, 'group', true, 'distance', phW.sp);
   if(ring > 1)
      infoIn = MergeInfo(infoIn, tInfoIn);
   else
      infoIn = tInfoIn;
   end
end

[topcell, infoIn] = PlaceRect(topcell, infoIn, reshape([rings.straightLength; rings.straightLength] + [rings.radius; rings.radius], ringNum * 2, 1), phW.w, phW.layer, phW.dtype);
info = MergeInfo(infoIn, infoThru, infoCross);

[topcell, info] = PlaceRect(topcell, info, 50 - info.pos( : , 1) - phW.r, phW.w, phW.layer, phW.dtype);
[topcell, info] = PlaceArc(topcell, info, 90, phW.r, phW.w, phW.layer, phW.dtype, 'group', true, 'distance', phW.sp);

infoIn = SplitInfo(info, 1 : 2 * ringNum);
infoOut = SplitInfo(info, (2 * ringNum) + (1 : 2 * ringNum));


%% Save GDS and .mat cell information
FinalizeCell(cad, cellname, topcell, refs, infoIn, infoOut, log);

