function el = CheckForLargePolygons(el, varargin)
%%CHECKFORLARGEPOLYGONS cuts polygons larger that 8191 vertices

xy = el.xy;
sizes = cellfun(@(cell) size(cell, 1), xy);
options.maxVertices = 8190;
options = ReadOptions(options, varargin{:});
mask = sizes > options.maxVertices;

loop = 1;
while(any(mask))
  
  if(any(~mask))
    elSmall = gds_element('boundary', 'xy', xy(~mask), 'layer', get(el, 'layer'), 'dtype', get(el, 'dtype'));
  else
    elSmall = [];
  end
  allCorners = cell2mat(cellfun(@(t)[min(t, [], 1) , max(t, [], 1)], xy(mask), 'UniformOutput', false)');
  
  elBigs = cell(1, sum(mask));
  xyBig = xy(mask);
  sizesBig = sizes(mask);
  for index = 1 : sum(mask)
    
    curEl = gds_element('boundary', 'xy', xyBig(index), 'layer', get(el, 'layer'), 'dtype', get(el, 'dtype'));
    corners = [allCorners(index,1), allCorners(index,2); allCorners(index,3), allCorners(index,4)];
    multiplier = sizesBig(index) / options.maxVertices * loop;
    
    elWidth = (corners(2, 1) - corners(1, 1));
    elHeight = (corners(2, 2) - corners(1, 2));
    numRowCol = ceil([elWidth, elHeight] / max([elHeight, elWidth]) * multiplier) + 1;
    
    checkerboard1 = CheckerBoard(numRowCol(1), numRowCol(2), corners, 1);
    checkerboard2 = CheckerBoard(numRowCol(1), numRowCol(2), corners, 2);
    checkerboard3 = CheckerBoard(numRowCol(1), numRowCol(2), corners, 3);
    checkerboard4 = CheckerBoard(numRowCol(1), numRowCol(2), corners, 4);
    

    el1 = poly_bool(curEl, checkerboard1, 'and');
    el2 = poly_bool(curEl, checkerboard2, 'and');
    el3 = poly_bool(curEl, checkerboard3, 'and');
    el4 = poly_bool(curEl, checkerboard4, 'and');
    
    curEl = MergeElements({el1, el2, el3, el4});
    
    elBigs{index} = curEl;
    
  end
  if(any(~mask))
    el = MergeElements([{elSmall}, elBigs]);
  else
    el = MergeElements(elBigs);
  end
  
  loop = loop + 1;
  xy = el.xy;
  sizes = cellfun(@(cell) size(cell, 1), xy);
  mask = sizes > options.maxVertices;
end

end



function checkerboard = CheckerBoard(colNum, rowNum, corners, index, varargin)
%%CHECKERBOARD creates a checkerboard gds_element


options.layer = 0;
options.dtype = 0;
options.invert = false;
options = ReadOptions(options, varargin{:});
checkerboard = [];

colWidth = (corners(2, 1) - corners(1, 1)) / colNum;
rowHeight = (corners(2, 2) - corners(1, 2)) / rowNum;

for col = 1 : colNum
  for row = 1 : rowNum
    
    if((4 - mod(col, 2) - 2 * mod(row, 2)) == index)
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






