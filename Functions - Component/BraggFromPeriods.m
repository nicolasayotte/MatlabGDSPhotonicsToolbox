function obragg = BraggFromPeriods(w, period, corw, dc, layer, dtype)

%BRAGGFROMPARAMETERS Create a bragg grating information structure
%Author : Nicolas Ayotte                                   Creation date : 26/03/2014
%
%
%     bragg = BraggFromParameters(len, w, period, corw, dc, chirp, phaseShift, layer,
%             dtype)
%
%
%     ARGUMENT NAME     SIZE                  DESCRIPTION
%     'w'               1|n x 1|m             width
%     'period'          {1 x 1|m} 1|n x 1|p   period
%     'corw'            1|n x 1|m             corrugation width
%     'dc'              1|n x 1|m             duty cycle
%     Je vais ajouter un varargin de "phase_shift"....j'aime mieux les mettre discrets dans le code
%
%     If the number of rows (n) in any of the arguments is higher that 1 then the output
%     bragg structure will be a array of size n x 1
%
%     ** These strucutre fields are mandatory to use with PlaceStructure **
%
%     FIELD NAME     SIZE              DESCRIPTION
%     'xy'           {1 x m {1 x p}}   period and waveguide polygons
%     'layer'        1|n x m           layer for polygons
%     'dtype'        1|n x m           datatype for polygons
%     'pos'          1|n x 2           distance from (0, 0) to grating end
%     'ori'          1                 angle change from 0 to grating end orientation
%     'len'          1                 length change from 0 to grating end orientation
%
%
%     See also PlaceStructure, BraggFromProfile, Waveguide, FiberArray, Taper

rows = max([size(layer, 1), size(dtype, 1), size(w, 1), size(period, 1), size(corw, 1), size(dc, 1)]);
cols = max([size(layer, 2), size(dtype, 2), size(w, 2), size(corw, 2)]);

obragg(rows, 1) = struct('xy', [], 'layer', [], 'dtype', [], 'pos', [], 'ori', 0, 'len', [], ...
  'w', 0, 'period', 0, 'corw', 2, 'dc', 0.5, 'phaseShift', []);

[layer, dtype, w, period, corw, dc] = NumberOfRows(rows, layer, dtype, w, period, corw, dc);
[layer, dtype, w, corw] = NumberOfColumns(cols, layer, dtype, w, corw);


for row = 1 : rows
  
  pers = size(period{row}, 1);
  spatialPeriod = period{row};
  spatialDC = dc{row};
  
  [spatialPeriod, spatialDC] = NumberOfColumns(cols, spatialPeriod, spatialDC);
  [spatialPeriod, spatialDC] = NumberOfRows(pers, spatialPeriod, spatialDC);
  
  gratingLength = max(sum(spatialPeriod));
  % internal GDS structure fields
  obragg(row).xy = cell(1, cols);
  obragg(row).layer = layer(row, :);
  obragg(row).dtype = dtype(row, :);
  obragg(row).pos = [gratingLength, 0];
  obragg(row).ori = 0;
  obragg(row).len = gratingLength;
  
  % bragg fields
  obragg(row).w = w(row, :);
  obragg(row).period = spatialPeriod;
  obragg(row).corw = corw(row, :);
  obragg(row).dc = spatialDC;
  
  %% Linear Chirped Grating from parameters
  
  for col = 1 : cols
    
    npers = (obragg(row).w(col) > 0) + pers * (obragg(row). corw(col) > 0);
    grating = cell(1, npers);
    
    % Corrugations
    if(obragg(row).corw(col) > 0)
      x1 = cumsum(obragg(row).period(:, col));
      x2 = x1 + obragg(row).period(:, col) .* obragg(row).dc(:, col);
      
      y1 = (-0.5 * obragg(row).w(col) - obragg(row).corw(col)) * ones(pers, 1);
      y2 = y1 + obragg(row).w(col) + 2 * obragg(row).corw(col);
      
      if(exist('CornersToRects') == 3)
        grating(1:pers) = CornersToRects(x1, x2, y1, y2);
      else
        grating(1:pers) = num2cell(reshape([x1, x2, x2, x1, x1, y1, y1, y2, y2, y1]', 5, 2, length(x1)), [1, 2]);
      end
      
    end
    
    % Guide
    if(obragg(row).w(col) > 0)
      grating{end} = [gratingLength * [0; 1; 1; 0; 0], 0.5 *obragg(row).w(col) * [1; 1; -1; -1; 1]];
    end
    
    obragg(row).xy{col} = grating;
  end
end

return