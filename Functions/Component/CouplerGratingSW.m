function [ocoupler] = CouplerGratingSW(type, width, periods, indices, fillFactorExponent, layer, dtype, varargin)
%COUPLERGRATINGSW Create a subwabvelength coupler grating structure
%
%
%     REQUIRED FIELDS:
%     xy          {1 x m {1 x p}}  period and waveguide polygons
%     layer       [1 x m]          layer for polygons
%     dtype       [1 x m]          datatype for polygons
%     pos         [1 x 2]          distance from (0,0) to grating end
%     ori         [1]              angle change from 0 to grating end orientation
%     len         [1]              length change from 0 to grating end orientation


%% Input arguments
rows = max([size(periods, 1), size(indices, 1), size(layer, 1), size(dtype, 1), size(width, 1)]);
[type, width, periods, indices, fillFactorExponent, layer, dtype] = NumberOfRows(rows, type, width, periods, indices, fillFactorExponent, layer, dtype);

ocoupler(rows, 1) = struct('xy', [], 'layer', [], 'dtype', [], 'pos', [], 'ori', 0, 'len', [], ...
  'periods', [], 'indices', [], 'width', [], 'type', '', 'fillFactorExponent', 1);

for row = 1 : rows
  cols = size(layer, 2);
  
  [widthRow, periodsRow, indicesRow] = NumberOfColumns(cols, width(row, :), periods{row}, indices{row});
  
  lengthRow = max(cellfun(@(x)sum(x), periodsRow));
  
  ocoupler(row).xy = cell(1, cols);
  ocoupler(row).layer = layer(row, :);
  ocoupler(row).dtype = dtype(row, :);
  ocoupler(row).pos = [lengthRow, 0];
  ocoupler(row).len = lengthRow;
  ocoupler(row).ori = 0;
  
  ocoupler(row).type = type{row};
  ocoupler(row).width = widthRow;
  ocoupler(row).periods = periodsRow;
  ocoupler(row).indices = indicesRow;
  ocoupler(row).fillFactorExponent = fillFactorExponent(row);
  ocoupler(row) = ReadOptions(ocoupler(row), varargin{:});

  
  switch ocoupler(row).type
    case 'lateral'
      ocoupler(row) = LateralGrating(ocoupler(row), cols);
    otherwise
      error('Grating coupler type');
  end
end
end


function ocoupler = LateralGrating(ocoupler, cols)

for col = 1 : cols
  periodCol = ocoupler.periods{col};
  periodNum = length(periodCol);
  
  if(~isempty(periodCol) && periodNum > 1)
    [x1, x2, y1, y2] = LateralSubwavelengthGrating(ocoupler, col);
  else
    x1 = 0;
    x2 = periodCol;
    y1 = -ocoupler.width(col) / 2;
    y2 = ocoupler.width(col) / 2;
  end
  
  if(exist('CornersToRects.mexw64', 'file') == 3)
    grating = CornersToRects(x1, x2, y1, y2);
  else
    grating = num2cell(reshape([x1, x2, x2, x1, x1, y1, y1, y2, y2, y1]', 5, 2, length(x1)), [1, 2]);
  end
  ocoupler.xy{col} = grating;
end

end



function [x1, x2, y1, y2] = LateralSubwavelengthGrating(ocoupler, col)
x = [0; cumsum(ocoupler.periods{col})];

x1 = []; x2 = x1; y1 = x1; y2 = x1;
for ii = 1 : length(ocoupler.indices{col})
  index = ocoupler.indices{col}(ii);
  [ty1, ty2] = LinearDistribution(index, ocoupler.width(col), ocoupler.fillFactorExponent);
  tx1 = repmat(x((0) + ii), 1, length(ty1));
  tx2 = repmat(x((1) + ii), 1, length(ty1));
  x1 = [x1, tx1];
  x2 = [x2, tx2];
  y1 = [y1, ty1];
  y2 = [y2, ty2];
end
end


function [y1, y2] =  LinearDistribution(index, width, exponent)
SPACE_MIN = 60e-3;
SPACE_MAX = 1550e-3 / 2;
LINE_MIN = 60e-3;
LINE_MAX = 1550e-3 / 2 / 2.9;

indices = load('dataCouplers/indicesAir');

rindex_max = interp1(indices.refractive, indices.effective, 3.47);
rindex = interp1(indices.refractive, indices.effective, index);

fillFactor = (rindex^exponent - 1) / (rindex_max^exponent - 1);

if(fillFactor >= 0.5)
  space = SPACE_MIN;
  line = fillFactor * space/ (1 - fillFactor);
else
  line = LINE_MIN;
  space = (1 - fillFactor) * line / fillFactor;
end

if(line > LINE_MAX)
  y1 = -width / 2;
  y2 = width / 2;
elseif(space > SPACE_MAX)
  y1 = [];
  y2 = [];
else
  period = line + space;
  y1 = (0 : period : width - line);
  y2 = (line : period : width);
  yMean = max(y2) / 2;
  y1 = y1 - yMean;
  y2 = y2 - yMean;
end

end