function oring = Microring(gap, layer, dtype, varargin)
%MICRORING Create a microring information structure
%Author: Nicolas Ayotte                                     Creation date: 13/05/2013
%
%     This function receives the ring radius, straight section length (if 
%     it is a racetrack), gap size, width, layer and dataype.
%
%     It is possible to enter any two of the four 'radius', 'w', 'radiusmax',
%     or 'radiusmin' to define your disk/ring structure.
% 
%     See also PLACEMICRORING, WAVEGUIDE.

rows = max([size(gap, 1), size(layer, 1), size(dtype, 1)]);
[gap, layer, dtype] = NumberOfRows(rows, gap, layer, dtype);


oring(rows, 1) = struct('radius', [], 'w', [], 'radiusmin', [], 'radiusmax', [], 'gap', [], 'layer', [], 'dtype', [], ...
  'position', 'over', 'resolution',  50e-3, 'straightLength', 0);


for row = 1 : rows
  % Microring fields
  oring(row).gap = gap(row, :);
  oring(row).couplingLength = 0;
  oring(row).layer = layer(row, :);
  oring(row).dtype = dtype(row, :);
end

oring = ReadOptions(oring, varargin{:});
oring = VerifyRadiusInfo(oring);

end



function oring = VerifyRadiusInfo(oring)

rows = size(oring, 1);
for row = 1 : rows
  maskinfo = [isempty(oring(row).radius) isempty(oring(row).w) isempty(oring(row).radiusmin) isempty(oring(row).radiusmax)];
  if(sum(maskinfo) < 2)
    error('Microring object need at least two of those four options: radius, w, radiusmin, radiusmax.');
  end
  
  if(maskinfo(1))
    if(~maskinfo(2))
      if(~maskinfo(3))
        oring(row).radius = oring(row).radiusmin + oring(row).w / 2 ;
      else
        oring(row).radius = oring(row).radiusmax - oring(row).w / 2 ;
      end
    else
      oring(row).radius = (oring(row).radiusmin + oring(row).radiusmax) / 2;
    end
  end
  
  if(maskinfo(2))
    if(~maskinfo(3))
      oring(row).w = 2 * (oring(row).radius - oring(row).radiusmin);
    else
      oring(row).w = 2 * (oring(row).radiusmax - oring(row).radius);
    end
  end
  
  if(maskinfo(3))
    oring(row).radiusmin = oring(row).radius - oring(row).w / 2;
  end
  
  if(maskinfo(4))
    oring(row).radiusmax = oring(row).radius + oring(row).w / 2;
  end
end

end