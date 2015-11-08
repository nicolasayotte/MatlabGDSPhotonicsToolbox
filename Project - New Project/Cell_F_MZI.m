%% MZI
% Author : Alexandre D. Simard
% Creation date : 06/19/2014
% The entire programs is in microns.


%% Initialize Cell Parameters
tp = cd; cd ../Functions/; addpath(genpath(cd)); cd(tp);     % add path to every folder of the library
[log, cad, cellname, topcell, layerMap] = InitializeCell();


%% Load GDS Library References
refs(1).filename = '../Library/GratingCouplerDummy.gds';
refs(1).cellname = 'GratingCouplerDummy';

refs(2).filename = '../Library/Ybranch.gds';
refs(2).cellname = 'Ybranch';
refs(2).dy = 5.7;
refs = GetRefsFloorplan(refs);


%% Define Cellref Objects
phW = Waveguide([0.5, 3.5], [layerMap.FullCore, layerMap.FullClad], 5, 5);


%% Initialize the cell inputs and outputs
waveguideCount = 5;
posx = 250 * (0 : waveguideCount - 1)';
posy = 0 * posx;
info = CursorInfo([posx, posy], 180, 1);


% Write text at the initial cursor positions for automatic measures
strEl = arrayfun(@(x, y, n) gds_element('text', 'text', ['opt_in_TE_1550_device_NicolasAyotte_MZI', num2str(n)],...
    'xy', [x, y], 'layer', layerMap.TXT(1)), info.pos( : , 1), info.pos( : , 2), (1:length(info.ori))', 'UniformOutput', 0);
topcell = add_element(topcell, strEl');


% Place the Input couplers
[topcell, infoOut] = PlaceRef(topcell, info, refs(1).cellname);
[topcell, infobranch1, infobranch2, ybranchinfo] = ...
    PlaceYbranch(topcell, infoOut, 1, refs(2).dy, refs(2).cellname, refs(2).filename);  % input coupler y-branch


% Branch 1
[topcell, infobranch1] = PlaceRect(topcell, infobranch1, 100, phW.w, phW.layer, phW.dtype);
[topcell, infobranch1] = PlaceArc(topcell, infobranch1, 90, phW.r, phW.w, phW.layer, phW.dtype);
[topcell, infobranch1] = PlaceRect(topcell, infobranch1, 70, phW.w, phW.layer, phW.dtype);
[topcell, infobranch1] = PlaceArc(topcell, infobranch1, 90, phW.r, phW.w, phW.layer, phW.dtype);
[topcell, infobranch1] = PlaceRect(topcell, infobranch1, 100, phW.w, phW.layer, phW.dtype);

% Branch 2
[topcell, infobranch2] = PlaceRect(topcell, infobranch2, 130, phW.w, phW.layer, phW.dtype);
[topcell, infobranch2] = PlaceArc(topcell, infobranch2, 90, phW.r, phW.w, phW.layer, phW.dtype);
[topcell, infobranch2] = PlaceRect(topcell, infobranch2, 70 + 2 * refs(2).dy, phW.w, phW.layer, phW.dtype);
[topcell, infobranch2] = PlaceArc(topcell, infobranch2, 90, phW.r, phW.w, phW.layer, phW.dtype);
[topcell, infobranch2] = PlaceRect(topcell, infobranch2, 130, phW.w, phW.layer, phW.dtype);


% Output y-branches and couplers
[topcell, infobranch1, infobranch2, ybranchinfo] = ...
    PlaceYbranch(topcell, infobranch1, 3, refs(2).dy, refs(2).cellname, refs(2).filename);  % output coupler y-branch
[topcell, ~] = PlaceRef(topcell, infobranch1, refs(1).cellname); % input coupler


infoIn = [];  % inputs % No external routing
infoOut = [];  % outputs % No external routing


%% Save GDS and .mat cell information
FinalizeCell(cad, cellname, topcell, refs, infoIn, infoOut, log);

