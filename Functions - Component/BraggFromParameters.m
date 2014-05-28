function obragg = BraggFromParameters(len, w, period, corw, dc, chirp, phaseShift, layer, dtype)

%BRAGGFROMPARAMETERS Create a bragg grating information structure
%Author : Nicolas Ayotte                                   Creation date : 26/03/2014
% 
% 
%     bragg = BraggFromParameters(len, w, period, corw, dc, chirp, phaseShift, layer,
%             dtype)
%
%
%     ARGUMENT NAME     SIZE           DESCRIPTION
%     'len'             1|n x 1        length of the grating
%     'w'               1|n x 1|m      width
%     'period'          1|n x 1|m      period
%     'corw'            1|n x 1|m      corrugation width
%     'dc'              1|n x 1|m      duty cycle
%     'chirp'           1|n x 1|m      chirp
%     'phaseShift'      1|n x 1|m      phase shifts
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

rows = max([size(len, 1), size(layer, 1), size(dtype, 1), size(w, 1), size(period, 1), size(corw, 1), size(dc, 1), size(chirp, 1)]);
cols = max([size(layer, 2), size(dtype, 2), size(w, 2), size(period, 2), size(corw, 2), size(dc, 2), size(chirp, 2)]);

obragg(rows, 1) = struct('xy', [], 'layer', [], 'dtype', [], 'pos', [], 'ori', 0, 'len', [], ...
  'w', 0, 'period', 0, 'corw', 2, 'dc', 0.5, 'phaseShift', []);


[len, layer, dtype, w, period, corw, dc, phaseShift, chirp] = NumberOfRows(rows, len, layer, dtype, w, period, corw, dc, phaseShift, chirp);
[layer, dtype, w, period, corw, dc, phaseShift, chirp] = NumberOfColumns(cols, layer, dtype, w, period, corw, dc, phaseShift, chirp);


for row = 1 : rows
  cols = size(layer, 2);
  
  % internal GDS structure fields
  obragg(row).xy = cell(1, cols);
  obragg(row).layer = layer(row, :);
  obragg(row).dtype = dtype(row, :);
  obragg(row).pos = [len(row),0];
  obragg(row).ori = 0;
  obragg(row).len = len(row);
  
  % bragg fields
  obragg(row).w = w(row, :);
  obragg(row).period = period(row, :);
  obragg(row).corw = corw(row, :);
  obragg(row).dc = dc(row, :);
  obragg(row).chirp = chirp(row, :);
  if(~isempty(phaseShift))
    obragg(row).phaseShift = phaseShift(row, :);
  end
  
  % VERIFY NUMBER OF COLUMNS
  
  %% Linear Chirped Grating from parameters

  for col = 1 : cols
     if(~isempty(phaseShift))
        periods = round((obragg(row).len - obragg(row).period(col) * sum(obragg(row).phaseShift(col).value/(2 * pi)) - (1-obragg(row).dc(col)) * obragg(row).period(col))/(obragg(row).period(col) + 0.5 * obragg(row).chirp(col)));
     else
        periods = round((obragg(row).len - (1-obragg(row).dc(col)) * obragg(row).period(col))/(obragg(row).period(col) + 0.5 * obragg(row).chirp(col)));
     end
  
    % Number of elements
    rows = 0;
    if(obragg(row).corw(col) > 0); rows = rows + periods; end
    if(obragg(row).w(col) > 0); rows = rows + 1; end
    grating = cell(1, rows);
    
    % Corrugations
    if(obragg(row).corw(col) > 0)
      x1 = cumsum(obragg(row).period(col) + linspace(0, obragg(row).chirp(col), periods)') - obragg(row).period(col);
      if(~isempty(obragg(row).phaseShift))
        if(~isempty(obragg(row).phaseShift(col).pos))
          tps = zeros(periods,1); tps(round(obragg(row).phaseShift(col).pos * periods)) = obragg(row).phaseShift(col).value * obragg(row).period(col) / (2 * pi);
          x1 = x1 + cumsum(tps);
        end
      end
      x2 = x1 + obragg(row).period(col) * obragg(row).dc(col);
      
      y1 = (-0.5 * obragg(row).w(col) - obragg(row).corw(col)) * ones(periods,1);
      y2 = y1 + obragg(row).w(col) + 2 * obragg(row).corw(col);
      
      for kk = 1 : periods
        grating{kk} = [x1(kk), y1(kk); x2(kk), y1(kk); x2(kk), y2(kk); x1(kk), y2(kk); x1(kk), y1(kk)];
      end
    end
    
    % Guide
    if(obragg(row).w(col) > 0)
      grating{end} = [obragg(row).len * [0; 1; 1; 0; 0], 0.5 *obragg(row).w(col) * [1; 1; -1; -1; 1]];
    end
    
    obragg(row).xy{col} = grating;
  end
end

return