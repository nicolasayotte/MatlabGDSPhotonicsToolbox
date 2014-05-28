function [topcell, cellInfo, infoIn, infoOut, varargout] = PutCell(topcell, cad, cellInfo, layerMap, cellname, varargin)
%%PUTCELL Create a cell positioning information in the master .gds
% Author: Nicolas Ayotte                                    Creation Date: 26/04/2014
%
%     This function creates a cellname'_put.mat' file with the positioning information
%     for the cell placement. This includes a rectangle on the GDS floorplan layer
%
%     ARGUMENT NAME     SIZE        DESCRIPTION
%     topcell           1           gds_structure library object
%     cad               1           cad information struct
%     cellInfo          m x 1       cells floorplan and placement information
%     layerMap          1           layermap information struct
%     cellname          string      name of the current cell
%
%     local struct putCell
%
%     OPTION NAME       SIZE        DESCRIPTION
%     'anchor'          string      ['floorplan'] or a cell name for positioning reference
%     'verticalAlign'   string      ['topOutside'], 'topInside', 'bottomOutside', 'bottomInside', 'center'
%     'horizontalAlign' string      ['leftOutside'], 'leftInside', 'rightOutside', 'rightInside', 'center'
%     'offset'          1 x 2       [0, 0] offset from anchor position
%     'strans'          struct      reflection and rotation of the cell
%     'anchorIndex'     1           [1] index of reference to multiple cell occurences
%     'anchorHorizontal string      [] (optional) independent horizontal anchor
%     'anchorVertical   string      [] (optional) independent vertical anchor
%
%     See also MERGEGDS.


%% Read options
putCell = struct('anchor', 'floorplan', 'verticalAlign', 'topOutside', 'horizontalAlign', 'rightOutside',...
   'offset', [0, 0], 'strans', struct('reflect', 0, 'angle', 0), 'anchorIndex', 1,...
   'anchorHorizontal', [], 'anchorVertical', []);
putCell = ReadOptions(putCell, varargin{:});

makename = @(x) [cad.author '_' x '_' cad.v];
cellname = makename(cellname);


%% Determine required translation
anchorType = {'Horizontal', 'Vertical'};
translation = [0, 0];
for anchorNum = 1 : 2
   
   if(~isempty(putCell.(['anchor' anchorType{anchorNum}])))
      anchor = ['anchor' anchorType{anchorNum}];
   else
      anchor = 'anchor';
   end
   
   switch putCell.(anchor)
      
      case 'absolute'
         
         translation = putCell.offset;
         continue;
         
      case 'floorplan'
         
         % Determine the cell floorplan rectangle position
         if(anchorNum == 1); cellRect = StransXY(cellInfo.(cellname).floorplan.rect, [0, 0], putCell.strans); end
         refrect = MakeRect([0, 0], cad.size, 'margin', cad.margin);
         [cellRect, t] = Positioning(cellRect, refrect, putCell, anchorType{anchorNum});
         translation = translation + t;
      otherwise
         
         % Place cell relative to another cell
         if(anchorNum == 1); cellRect = StransXY(cellInfo.(cellname).floorplan.rect, [0, 0], putCell.strans); end
         refrect = StransXY(cellInfo.(makename(putCell.(anchor))).floorplan.rect, cellInfo.(makename(putCell.(anchor))).spos(putCell.anchorIndex, :), cellInfo.(makename(putCell.(anchor))).strans(putCell.anchorIndex));
         [cellRect, t] = Positioning(cellRect, refrect, putCell, anchorType{anchorNum});
         translation = translation + t;
   end
end

putCell.strans = CorrectStransFields(putCell.strans);

%% Create (or append) the cell placement information
if(isfield(cellInfo, cellname))
   if(isfield(cellInfo.(cellname), 'spos'));
      spos = cellInfo.(cellname).spos;
      strans = cellInfo.(cellname).strans;
      spos(end + 1, 1:2)  = translation;
      strans(end + 1) = putCell.strans;
   else
      spos = translation;
      strans = putCell.strans;
   end
   if(~isempty(cellInfo.(cellname).infoIn))
      infoIn = StransInfo(cellInfo.(cellname).infoIn, translation, putCell.strans);
   else
      infoIn = [];
   end
   if(~isempty(cellInfo.(cellname).infoOut))
      infoOut = StransInfo(cellInfo.(cellname).infoOut, translation, putCell.strans);
   else
      infoOut = [];
   end
else
   spos = translation;
   strans = putCell.strans;
   infoIn = [];
   infoOut = [];
end

filename = ['Cells/' cellname '.gds'];
save(['Cells/' cellname '_put'], 'filename', 'cellname', 'spos', 'strans');


cellInfo.(cellname).spos = spos;
cellInfo.(cellname).strans = strans;

%% Draw cell floorplan rectangle and identifier
if(exist('cellRect', 'var'))
   limitElement = gds_element('boundary', 'xy', cellRect, 'layer', layerMap.FP(1), 'dtype', layerMap.FP(2));
   topcell = add_element(topcell, limitElement);
   varargout{1} = cellRect;
   
   strEl = gds_element('text', 'text', cellname, 'xy', mean(cellRect), 'layer', layerMap.TXT(1), 'verj', 1, 'horj', 1);
   topcell = add_element(topcell, strEl);
   
   if(~isempty(infoIn))
      IsEl = arrayfun(@(x, y) gds_element('text', 'text', 'X', 'xy', [x, y], 'layer', layerMap.TXT(1), 'verj', 1, 'horj', 1), infoIn.pos(:,1), infoIn.pos(:,2), 'UniformOutput', 0);
      topcell = add_element(topcell, IsEl');
   end
   if(~isempty(infoOut))
      OsEl = arrayfun(@(x, y) gds_element('text', 'text', 'O', 'xy', [x, y], 'layer', layerMap.TXT(1), 'verj', 1, 'horj', 1), infoOut.pos(:,1), infoOut.pos(:,2), 'UniformOutput', 0);
      topcell = add_element(topcell, OsEl');
   end
   
end

end



function [orect, translation] = Positioning(cellRect, refrect, putCell, anchorType)
translation = [0, 0];

if(strcmpi(anchorType, 'Vertical'))
   switch putCell.verticalAlign
      case 'bottomInside'
         tgty = min(cellRect(:, 2));
         refy = min(refrect(:, 2));
      case 'topInside'
         tgty = max(cellRect(:, 2));
         refy = max(refrect(:, 2));
      case 'center'
         tgty = mean(cellRect(1 : 4, 2));
         refy = mean(refrect(1 : 4, 2));
      case 'bottomOutside'
         tgty = max(cellRect(:, 2));
         refy = min(refrect(:, 2));
      case 'topOutside'
         tgty = min(cellRect(:, 2));
         refy = max(refrect(:, 2));
      otherwise
         error('This alignment is not supported');
   end
   translation(2) = refy - tgty  + putCell.offset(2);
end

if(strcmpi(anchorType, 'Horizontal'))
   switch putCell.horizontalAlign
      case 'leftInside'
         tgtx = min(cellRect(:, 1));
         refx = min(refrect(:, 1));
      case 'rightInside'
         tgtx = max(cellRect(:, 1));
         refx = max(refrect(:, 1));
      case 'center'
         tgtx = mean(cellRect(1 : 4, 1));
         refx = mean(refrect(1 : 4, 1));
      case 'leftOutside'
         tgtx = max(cellRect(:, 1));
         refx = min(refrect(:, 1));
      case 'rightOutside'
         tgtx = min(cellRect(:, 1));
         refx = max(refrect(:, 1));
      otherwise
         error('This alignment is not supported');
   end
   translation(1) = refx - tgtx + putCell.offset(1);
end

orect = RotTransXY(cellRect, translation, 0);
end