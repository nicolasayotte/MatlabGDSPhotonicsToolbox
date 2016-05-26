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
xyref = cell(1, 0);

for sref = 1 : length(srefs)
    isref = false;
    iscell = false;
    for index = 1 : length(refs)
        if(strcmpi(refs(index).cellname, get(srefs{sref}, 'sname')))
            isref = true;
            break;
        end
    end
    if isref
        floorplan = refs(index).floorplan;
        txy = [floorplan.xy ; floorplan.xy + [floorplan.size(1), 0];...
            floorplan.xy + floorplan.size; floorplan.xy + [0, floorplan.size(2)]; floorplan.xy];
    else
        for index = 1 : length(cells)
            if(strcmpi(get(cells{index}, 'sname'), get(srefs{sref}, 'sname')))
                iscell = true;
                break;
            end
        end
        if iscell
            if(isfield(cells{index}, 'floorplan'))
                floorplan = cells{index}.floorplan;
            else
                [cellrect, cellcenter, cellsize] = GetStructureSize(cells{index});
                floorplan = struct('rect', cellrect, 'xy', cellcenter, 'size', cellsize);
            end
            txy = floorplan.rect;
        end
    end
    
    % Getting the four corners of the referenced cell floorplan
    %txy = [floorplan.xy ; floorplan.xy + [floorplan.size(1), 0];...
    %    floorplan.xy + floorplan.size; floorplan.xy + [0, floorplan.size(2)]; floorplan.xy];
    
    % Placing those points in their absolute position in the cell
    positions = get(srefs{sref}, 'xy');
    for i = 1 : size(positions, 1)
        xyref = [xyref, StransXY(txy, positions(i, 1:2), get(srefs{sref}, 'strans'))];
    end
    
end

%% Boundary
xyall = vertcat(xybnds{:}, xyref{:});   % Array of every point coordinates in the cell
extrema = [min(xyall); max(xyall)];

cellsize = diff(extrema, 1);
cellrect = MakeRect(extrema(1,:), cellsize);
center = [mean(cellrect(:, 1)), mean(cellrect(:, 2))];
end