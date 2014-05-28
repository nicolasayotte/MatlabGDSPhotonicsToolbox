function [cellrect, center, cellsize] = GetStructureSize(st, refs, cells)
%GETSTRUCTURESIZE Find the rectangular area occupied by a gds_structure.
%
%     st: gds_structure object containing boudaries and refs
%     refs: the refs structure of library GDS files referenced in this structure
%            as created per GetRefsFLoorplan
%     cells: the cells structure of other GDS files referenced in this structure
%            as created per GetCellInfo
%
%     See also GETREFSFLOORPLAN, GETCELLINFO

if(nargin < 2); refs = []; end
if(nargin < 3); cells = []; end

srefs = find(st, @(el) is_etype(el, 'sref') || is_etype(el, 'aref'));
bounds = find(st, @(el) is_etype(el, 'boundary') || is_etype(el, 'path'));


%% Boundary objects
xybnds = cellfun(@(x) get(x, 'xy'), bounds, 'UniformOutput', false);
xybnds = horzcat(xybnds{:});
if(isempty(xybnds)); xybnds = {}; end

%% SRef objects
xyref = cell(1, length(srefs));

for sref = 1 : length(srefs)
  isref = false;
  iscell = false;
  for index = 1 : length(refs)
    if(strcmpi(refs(index).cellname, get(srefs{sref}, 'sname')))
      isref = true;
      continue;
    end
  end
  
  if isref
    floorplan = refs(index).floorplan;
  else
    for index = 1 : length(cells)
      if(strcmpi(cells(index).inptop, get(srefs{sref}, 'sname')))
        iscell = true;
        continue;
      end
    end
    if iscell
      floorplan = cells(index).floorplan;
    end
  end
  
  % Getting the four corners of the referenced cell floorplan
  txy = [floorplan.xy ; floorplan.xy + [floorplan.size(1), 0];...
    floorplan.xy + floorplan.size; floorplan.xy + [0, floorplan.size(2)]; floorplan.xy];
  
  % Placing those points in their absolute position in the cell
  xyref{sref} = StransXY(txy,  get(srefs{sref}, 'xy'), get(srefs{sref}, 'strans'));
end

%% Boundary
xyall = vertcat(xybnds{:}, xyref{:});   % Array of every point coordinates in the cell
extrema = [min(xyall); max(xyall)];

cellsize = diff(extrema, 1);
cellrect = MakeRect(extrema(1,:), cellsize);
center = [mean(cellrect(:, 1)), mean(cellrect(:, 2))];
end