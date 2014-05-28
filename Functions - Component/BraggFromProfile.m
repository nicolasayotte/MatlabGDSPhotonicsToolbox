function [obragg] = BraggFromProfile(spatialVector, spatialPhase, apodization, period, corw, dc, w, pillarSpacing, order, layer, dtype, varargin)

%BRAGGFROMPROFILE Create a bragg structure
% 
% 
%     REQUIRED FIELDS:
%     bragg.xy      {1 x m {1 x p}}  period and waveguide polygons
%     bragg.layer   [1 x m]          layer for polygons
%     bragg.dtype   [1 x m]          datatype for polygons
%     bragg.pos     [1 x 2]          distance from (0,0) to grating end
%     bragg.ori     [1]              angle change from 0 to grating end orientation
%     bragg.len     [1]              length change from 0 to grating end orientation


%% Input arguments
rows = max([size(period, 1), size(corw, 1), size(dc, 1), size(w, 1), size(pillarSpacing, 1), size(order, 1), size(layer, 1), size(dtype, 1)]);
[period, corw, dc, w, pillarSpacing, order, layer, dtype] = NumberOfRows(rows, period, corw, dc, w, pillarSpacing, order, layer, dtype);

obragg(rows, 1) = struct('xy', [], 'layer', [], 'dtype', [], 'pos', [], 'ori', 0, 'len', [], ...
  'spatialVector', [], 'spatialPhase', [], 'apodization', [], 'period', 0, 'corw', [],...
  'dc', 0.5, 'w', [], 'pillarSpacing', 0, 'order', 0, 'apodizationType', 'phase', 'apodizationFrequency', 0.4, ...
  'widthIsAverage', true);


for row = 1 : rows
  cols = size(layer, 2);
  
  len = abs(spatialVector(end) - spatialVector(1));
  
  % internal GDS structure fields
  obragg(row).xy = cell(1, cols);
  obragg(row).layer = layer(row, :);
  obragg(row).dtype = dtype(row, :);
  obragg(row).pos = [len, 0];
  obragg(row).ori = 0;
  obragg(row).len = len;
  
  % bragg fields
  obragg(row).spatialVector = spatialVector;
  obragg(row).spatialPhase = spatialPhase;
  obragg(row).apodization = apodization;
  obragg(row).w = w(row, :);
  obragg(row).period = period(row);
  obragg(row).order = order(row);
  obragg(row).corw = corw(row, :);
  obragg(row).dc = dc(row);
  obragg(row).pillarSpacing = pillarSpacing(row);
  obragg(row) = ReadOptions(obragg(row), varargin{:});
  
  periodNum = round(len/period(row) + 4e3);
  spatialVectorHi = linspace( - len/2, len/2, 2e5);
  spatialPhaseHi = interp1(obragg(row).spatialVector, obragg(row).spatialPhase, spatialVectorHi);
  spatialApodizationHi = interp1(obragg(row).spatialVector, obragg(row).apodization, spatialVectorHi);
  
  
  %% Phase profile
  switch obragg(row).apodizationType
    case 'amplitude'
      phi{1} = 2 * pi * spatialVectorHi ./ obragg(row).period + spatialPhaseHi;
      if ~obragg(row).widthIsAverage
        obragg(row).widthIsAverage = true;
        warning('Amplitude apodization requires widthIsAverage == true');
      end
      if (obragg(row).pillarSpacing ~= 0)
        obragg(row).pillarSpacing = 0;
        warning('Amplitude apodization requires pillarSpacing == 0')
      end
      
    case 'phase'
      phi{1} = 2 * pi*spatialVectorHi ./ obragg(row).period + spatialPhaseHi + 2.405 / (0.5 * pi * obragg(row).order)* ...
        acos((spatialApodizationHi) .^ 0.88) .* sin(obragg(row).apodizationFrequency * spatialVectorHi);
      
    case 'superposition'
      phi{1} = 2 * pi * spatialVectorHi ./ obragg(row).period + spatialPhaseHi + acos(spatialApodizationHi)/obragg(row).order;
      phi{2} = 2 * pi * spatialVectorHi ./ obragg(row).period + spatialPhaseHi - acos(spatialApodizationHi)/obragg(row).order;
      
    otherwise
      error('Apodization type not suppported. Try amplitude, phase or superposition');
  end
  
  if (obragg(row).widthIsAverage && any(obragg(row).w < obragg(row).corw))
    error('w cannot be smaller than corw');
  end
  
  phiNum = length(phi);
  
  %% Discretization
  [zintcos0, zintcos1, zintcosm1] = Discretization(periodNum, spatialVectorHi, phi);
  
  %% Final calculation
  shift2zero = zeros(1, phiNum);
  for ii = 1 : phiNum
    
    [zpos{ii}, dim{ii}] = sort([zintcos1{ii}, zintcosm1{ii}, zintcos0{ii}]);
    
    aa{ii} = [ones(1, length(zintcos1{ii})), zeros(1, length(zintcosm1{ii})), zeros(1, length(zintcos0{ii}))];
    aa{ii} = aa{ii}(dim{ii});  % Sort
    
    x1{ii} = zpos{ii}(find(aa{ii} == 1) - 1) + len / 2;  % initial spatial position of the grating periods
    x2{ii} = zpos{ii}(find(aa{ii} == 1) + 1) + len / 2;  % final spatial position of the grating periods
    
    % Duty Cycle
    pillarWidth = (x2{ii} - x1{ii})* 2 * obragg(row).dc;
    x2{ii} = x1{ii} + pillarWidth;
    
    shift2zero(ii) = x1{ii}(1);
  end
  
  % Make the first period start at zero
  for ii = 1 : phiNum
    x1{ii} = x1{ii} - min(shift2zero);
    x2{ii} = x2{ii} - min(shift2zero);
  end
  
  % Calculate the grating length
  obragg(row).len = 0;
  for ii = 1:1:length(phi)
    obragg(row).len = max([obragg(row).len, x2{ii}(end)]);
  end
  obragg(row).len = round(obragg(row).len*1000)/1000;  % 1nm grid.
  obragg(row).pos = [obragg(row).len,0];
  
  
  %% Defining the polygons
  switch obragg(row).apodizationType
    case 'amplitude'
      spatialApodizationHi1 = interp1(obragg(row).spatialVector - min(obragg(row).spatialVector), obragg(row).apodization, x1{1})';
      spatialApodizationHi2 = interp1(obragg(row).spatialVector - min(obragg(row).spatialVector), obragg(row).apodization, x2{1}(1:end - 1))';
      for col = 1 : cols
        if(obragg(row).corw(col))
          corwprofil = obragg(row).corw(col) * spatialApodizationHi1;
          widthprofil = obragg(row).w(col) * ones(length(corwprofil), 1);
          obragg1 = fct_poly_IBG(x1{1}', x2{1}', - widthprofil - corwprofil, 0, widthprofil + corwprofil);
          
          corwprofil = obragg(row).corw(col) * spatialApodizationHi2;
          widthprofil = obragg(row).w(col) * ones(length(corwprofil), 1);
          obragg2 = fct_poly_IBG(x2{1}(1:end - 1)', x1{1}(2:end)', - (widthprofil - corwprofil), 0, widthprofil - corwprofil);
          
          obragg(row).xy{col} = [obragg1, obragg2];
        else
          obragg3 = [0, - obragg(row).w(col)/2;...
            obragg(row).len, - obragg(row).w(col)/2;...
            obragg(row).len, obragg(row).w(col) /2;...
            0, obragg(row).w(col)/2;...
            0, - obragg(row).w(col)/2];
          obragg(row).xy{col} = {obragg3};
        end
      end
      
      
    case 'phase'
      if obragg(row).widthIsAverage
        
        for col = 1 : cols          
          obragg1 = fct_poly_IBG(x1{1}', x2{1}', ...
            (obragg(row).w(col) - obragg(row).corw(col)) * ones(length(x1{1}), 1),...
            obragg(row).pillarSpacing * ones(length(x1{1}), 1),...
            obragg(row).corw(col) * ones(length(x1{1}), 1));
          
          obragg2 = fct_poly_IBG(x1{1}', x2{1}',...
         - (obragg(row).w(col) - obragg(row).corw(col)) * ones(length(x1{1}), 1),...
         - obragg(row).pillarSpacing * ones(length(x1{1}), 1),...
         - obragg(row).corw(col) * ones(length(x1{1}), 1));
          
          if obragg(row).w(col) > 0
            obragg3 = [0, - (obragg(row).w(col) - obragg(row).corw(col))/2;...
              obragg(row).len, - (obragg(row).w(col) - obragg(row).corw(col))/2;...
              obragg(row).len, (obragg(row).w(col) - obragg(row).corw(col))/2;...
              0, (obragg(row).w(col) - obragg(row).corw(col))/2;...
              0, - (obragg(row).w(col) - obragg(row).corw(col))/2];
            obragg(row).xy{col} = [obragg1, obragg2, {obragg3}];
          else
            obragg(row).xy{col} = [obragg1, obragg2];
          end
        end
        
      else
        
        for col = 1 : cols
          obragg1 = fct_poly_IBG(x1{1}', x2{1}',...
            (obragg(row).w(col)) * ones(length(x1{1}), 1),...
            obragg(row).pillarSpacing * ones(length(x1{1}), 1),...
            obragg(row).corw(col) * ones(length(x1{1}), 1));
          
          obragg2 = fct_poly_IBG(x1{1}', x2{1}',...
         - (obragg(row).w(col)) * ones(length(x1{1}), 1),...
         - obragg(row).pillarSpacing * ones(length(x1{1}), 1),...
         - obragg(row).corw(col) * ones(length(x1{1}), 1));
          
          if obragg(row).w(col) > 0
            obragg3 = [0, - obragg(row).w(col)/2;...
              obragg(row).len, - obragg(row).w(col)/2;...
              obragg(row).len, obragg(row).w(col)/2;...
              0, obragg(row).w(col)/2; 0, - obragg(row).w(col)/2];
            obragg(row).xy{col} = [obragg1, obragg2, {obragg3}];
          else
            obragg(row).xy{col} = [obragg1, obragg2];
          end
        end
      end
      
      
    case 'superposition'
      if obragg(row).widthIsAverage
        
        for col = 1 : cols
          obragg1 = fct_poly_IBG(x1{1}', x2{1}',...
            (obragg(row).w(col) - obragg(row).corw(col)) * ones(length(x1{1}), 1),...
            obragg(row).pillarSpacing * ones(length(x1{1}), 1),...
            obragg(row).corw(col) * ones(length(x1{1}), 1));
          
          obragg2 = fct_poly_IBG(x1{2}', x2{2}',...
         - (obragg(row).w(col) - obragg(row).corw(col)) * ones(length(x1{2}), 1),...
         - obragg(row).pillarSpacing * ones(length(x1{2}), 1),...
         - obragg(row).corw(col) * ones(length(x1{2}), 1));
          
          if obragg(row).w(col) > 0
            obragg3 = [0, - (obragg(row).w(col) - obragg(row).corw(col))/2;...
              obragg(row).len, - (obragg(row).w(col) - obragg(row).corw(col))/2;...
              obragg(row).len, (obragg(row).w(col) - obragg(row).corw(col))/2;...
              0, (obragg(row).w(col) - obragg(row).corw(col))/2;...
              0, - (obragg(row).w(col) - obragg(row).corw(col))/2];
            obragg(row).xy{col} = [obragg1, obragg2, {obragg3}];
          else
            obragg(row).xy{col} = [obragg1, obragg2];
          end
        end
        
        
      else
        
        for col = 1 : cols
          obragg1 = fct_poly_IBG(x1{1}', x2{1}',...
            (obragg(row).w(col)) * ones(length(x1{1}), 1),...
            obragg(row).pillarSpacing * ones(length(x1{1}), 1),...
            obragg(row).corw(col) * ones(length(x1{1}), 1));
          
          obragg2 = fct_poly_IBG(x1{2}', x2{2}',...
         - (obragg(row).w(col)) * ones(length(x1{2}), 1),...
         - obragg(row).pillarSpacing * ones(length(x1{2}), 1),...
         - obragg(row).corw(col) * ones(length(x1{2}), 1));
          
          if obragg(row).w(col) > 0
            obragg3 = [0, - obragg(row).w(col)/2;...
              obragg(row).len, - obragg(row).w(col)/2;...
              obragg(row).len, obragg(row).w(col)/2;...
              0, obragg(row).w(col)/2;...
              0, - obragg(row).w(col)/2];
            obragg(row).xy{col} = [obragg1, obragg2, {obragg3}];
          else
            obragg(row).xy{col} = [obragg1, obragg2];
          end
        end
      end
  end
end
end



function [zintcos0, zintcos1, zintcosm1] = Discretization(periodNum, spatialVectorHi, phi)

phycos0 = pi/2 * (2 * ( - round(periodNum):round(periodNum)) + 1);
phycos1 = 2 * pi * ( - round(periodNum/2):round(periodNum/2));
phycosm1 = 2 * phycos0;

zintcos0 = cell(1, length(phi));
zint2cos0 = zintcos0;
zint2cos1 = zintcos0;
zintcos1 = zintcos0;
zint2cosm1 = zintcos0;
zintcosm1 = zintcos0;

for ii = 1 : length(phi)
  zint2cos0{ii} = interp1(phi{ii}, spatialVectorHi, phycos0);
  zintcos0{ii} = zint2cos0{ii}(logical(abs(isnan(zint2cos0{ii}) - 1)));
  
  zint2cos1{ii} = interp1(phi{ii}, spatialVectorHi, phycos1);
  zintcos1{ii} = zint2cos1{ii}(logical(abs(isnan(zint2cos1{ii}) - 1)));
  
  zint2cosm1{ii} = interp1(phi{ii}, spatialVectorHi, phycosm1);
  zintcosm1{ii} = zint2cosm1{ii}(logical(abs(isnan(zint2cosm1{ii}) - 1)));
end

% Gratings must start with zeros
for ii = 1 : length(phi)
  if zintcos1{ii}(1) < zintcos0{ii}(1)
    zintcos1{ii} = zintcos1{ii}(2:end);
  end
  if zintcos1{ii}(end) > zintcos0{ii}(end)
    zintcos1{ii} = zintcos1{ii}(1:end - 1);
  end
  
  if zintcosm1{ii}(1) < zintcos0{ii}(1)
    zintcosm1{ii} = zintcosm1{ii}(2:end);
  end
  if zintcosm1{ii}(end) > zintcos0{ii}(end)
    zintcosm1{ii} = zintcosm1{ii}(1:end - 1);
  end
end

end



function output = fct_poly_IBG(x1, x2, widthguide, squareguide, squaresize)

y1 = widthguide/2 + squareguide;
y2 = widthguide/2 + squareguide + squaresize;

output = cell(1, length(x1));
for kk = 1 : length(x1)
  output{kk} = [x1(kk), y1(kk); x2(kk), y1(kk); x2(kk), y2(kk); x1(kk), y2(kk); x1(kk), y1(kk)];
end
end

