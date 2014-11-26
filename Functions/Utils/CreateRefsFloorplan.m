function CreateRefsFloorplan(filename, forceUpdate)
%CREATEREFSFLOORPLAN Create a .mat file associated to the reference .gds file
% containing all the floorplan information for each structure.
%
%     This function receives the filename of a .gds and creates an information
%     structure .mat file
%
%     See also GETREFSFLOORPLAN

if(nargin < 2)
  forceUpdate = false;
end

if(forceUpdate || ~exist([filename(1:end-4) '.mat'], 'file'))
  gdslib = read_gds_library(filename);
  [A,N] = adjmatrix(gdslib(:));
  
  indices = find(sum(A, 1) == 0);
  refs = struct();
  cells = struct();
  for index = 1 : length(indices)
    [refs, cells] = CreateCellData(refs, cells, indices(index), A, N, gdslib);
  end
  
  save(filename(1:end-4), 'cells');
  save([filename(1:end-4) '_gds'], 'gdslib');
end

end


function [refs, cells] = CreateCellData(refs, cells, index, A, N, inlib)

if(sum(A(index, :) > 0))
  innerIndices = find(A(index, :) > 0);
  for innerIndex = 1 : length(innerIndices)
    [refs, cells] = CreateCellData(refs, cells, innerIndices(innerIndex), A, N, inlib);
  end
end

if(~isfield(cells, N{index}))
  [cellrect, ~, cellsize] = GetStructureSize(inlib(index), refs);
  cells.(N{index}).floorplan.xy = cellrect(1,:);
  cells.(N{index}).floorplan.size = cellsize;
  
  if((length(refs) == 1) && ~isfield(refs, 'floorplan'))
    refs.cellname = N{index};
    refs.floorplan = cells.(N{index}).floorplan;
  else
    refs(end + 1).cellname = N{index};
    refs(end).floorplan = cells.(N{index}).floorplan;
  end
end

end