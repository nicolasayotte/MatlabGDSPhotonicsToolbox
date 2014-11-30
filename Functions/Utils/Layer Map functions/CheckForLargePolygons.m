function el = CheckForLargePolygons(el)
%%CHECKFORLARGEPOLYGONS cuts polygons larger that 8191 vertices

xy = el.xy;
sizes = cellfun(@(cell) size(cell, 1), xy);
mask = sizes > 8190;

loop = 1;

while(any(mask))
  allCorners = cell2mat(cellfun(@(t)[min(t, [], 1) , max(t, [], 1)], xy, 'UniformOutput', false)');
  
  checkerboard = [];
  for index = 1 : length(sizes)
    if(mask(index))
      corners = [allCorners(index,1), allCorners(index,2); allCorners(index,3), allCorners(index,4)];
      multiplier = sizes(index) / 8190 * loop * 2;
      
      elWidth = (corners(2, 1) - corners(1, 1));
      elHeight = (corners(2, 2) - corners(1, 2));
      numRowCol = ceil([elWidth, elHeight] / max([elHeight, elWidth]) * multiplier);
      
      tchecker = CheckerBoard(numRowCol(1), numRowCol(2), corners);
      if(isempty(checkerboard))
        checkerboard = tchecker;
      else
        checkerboard = add_poly(checkerboard, tchecker.xy);
      end

    end
  end

  elCut = poly_bool(el, checkerboard, 'notb');
  elAnd = poly_bool(el, checkerboard, 'and');
  el = MergeElements({elCut, elAnd});
  
  loop = loop + 1;
  xy = el.xy;
  sizes = cellfun(@(cell) size(cell, 1), xy);
  mask = sizes > 8190;
end

end



function checkerboard = CheckerBoard(colNum, rowNum, corners, varargin)
%%CHECKERBOARD creates a checkerboard gds_element


options.layer = 0;
options.dtype = 0;
options = ReadOptions(options, varargin{:});
checkerboard = [];

colWidth = (corners(2, 1) - corners(1, 1)) / colNum;
rowHeight = (corners(2, 2) - corners(1, 2)) / rowNum;

for col = 1 : colNum
  for row = 1 : rowNum
    
    if(mod(col + row, 2))
      x0 = (col - 1) * colWidth + corners(1, 1);
      y0 = (row - 1) * rowHeight + corners(1, 2);
      rect = [x0, y0; x0 + colWidth, y0; x0 + colWidth, y0 + rowHeight; x0, y0 + rowHeight; x0, y0];
      if(isempty(checkerboard))
        checkerboard = gds_element('boundary', 'xy', rect, 'layer', options.layer, 'dtype', options.dtype);
      else
        checkerboard = add_poly(checkerboard, rect);
      end
    end
  end
end

end