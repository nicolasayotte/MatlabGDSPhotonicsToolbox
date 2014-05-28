function [structure, info, infoInput] = PlaceSBend(structure, info, len, h, r, wid, layer, datatype, varargin)
%PlaceSBend places s-bend polygons in a gds structure
%Author : Nicolas Ayotte                                       Creation date : 2/2/2014
% 
%     This function receives an input GDS structure and the parameters for one or
%     many s-bends to create and place at positions and orientations determined by
%     the info variable. It then updates info to the output positions.
% 
%     [struct, info, infoInput] = PlaceSBend(struct, info, len, h, r, wid, layer, info)
%     [struct, info] = PlaceSBend(struct, info, len, h, r, wid, layer, info, 'group', true)
% 
% 
%     ARGUMENT NAME     SIZE        DESCRIPTION
%     structure         1           gds_structure library object
%     r                 1           bend radius
%     len               m x 1       s-bend length in the propagation direction
%     h                 m x 1       s-bend offset in the normal direction
%     wid               m|1 x n|1   rect widths
%     layer             m|1 x n     layers
%     datatype          m|1 x n     datatypes
%     info.pos          m x 2       current position
%     info.ori          m|1 x 1     orientation angle in degrees
%     infoInput.pos     m x 2       input position
%     infoInput.ori     m|1 x 1     inverse of input orientation
%
%     OPTION NAME       SIZE        DESCRIPTION
%     'group'           1           [false] move as a group switch
%     'distance'        m - 1 x 1   [] relative guide spacing
%     'align'           string      ['center'] offset from the mean position
%                                   'top' offset from the top waveguide
%                                   'bottom' offset from the bottom waveguide
%     'type'            string      'normal' all layers turn smoothly
%                                   ['cladding'] even layer indices turn in straight segments
%                                   'metal' all layers turn in straight segments
% 
%     See also PlaceRect, PlaceArc, PlaceTaper

rows = size(info.pos, 1);
cols = size(layer, 2);


%% Default values for valid options
sbend.group = false;
sbend.distance = [];
sbend.align = 'center';
sbend.type = 'cladding';
sbend = ReadOptions(sbend, varargin{ : });


%% Argument validation
NonNegative(len, wid);
[len, wid, layer, datatype, info.ori] = NumberOfRows(rows, len, wid, layer, datatype, info.ori);
if(sbend.group && (rows > 1) && ~isempty(sbend.distance))
  sbend.distance = NumberOfColumns(rows - 1, sbend.distance);
end
wid = NumberOfColumns(cols, wid);
infoInput = InvertInfo(info);

if(sbend.group && rows > 1)
    info = CheckParallelAndNormal(info);
end


%% Group Routing
[verticalOffsets, lengthInput, lengthOutput] = CalculateOffsets(sbend, h, r, rows, info);
[lengthCenter, arcAngle] = CalculateAngleAndLength(len, r, rows, lengthInput, lengthOutput, verticalOffsets);


%% S-bend
[structure, info] = PlaceRect(structure, info, lengthInput, wid, layer, datatype);
[structure, info] = PlaceArc(structure, info, arcAngle, r, wid, layer, datatype, 'type', sbend.type);
[structure, info] = PlaceRect(structure, info, lengthCenter, wid, layer, datatype);
[structure, info] = PlaceArc(structure, info, -arcAngle, r, wid, layer, datatype, 'type', sbend.type);
[structure, info] = PlaceRect(structure, info, lengthOutput, wid, layer, datatype);

return



function [verticalOffsets, lengthInput, lengthOutput] = CalculateOffsets(sbend, meanVerticalOffset, r, rows, info)

if((rows > 1) && sbend.group)    % Group S-Bend
  relNormalSpacing = diff(info.pos, 1);
  absNormalSpacing = [0, 0; cumsum(relNormalSpacing, 1)];
  initialDistance = sqrt(sum(absNormalSpacing .* absNormalSpacing, 2));
  initialDistance = initialDistance - min(initialDistance);
  
  if(~isempty(sbend.distance))
    finalDistance = [0, cumsum(sbend.distance)]';
  else
    finalDistance = initialDistance;
  end
  
  distanceChange = finalDistance - initialDistance;
  switch sbend.align
    case 'bottom'
      align = 0;
    case 'top'
      align = distanceChange(end);
    otherwise
      align = distanceChange(end)/2;
  end
  verticalOffsets = meanVerticalOffset + distanceChange - align;

  lengthInput = zeros(rows, 1);
  lengthOutput = lengthInput;
  for row = 1 : rows
    if(abs(verticalOffsets(row)) < 1e-8)
      lengthInput(row) = 0;
      lengthOutput(row) = 0;
    elseif(verticalOffsets(row) < 0)
      lengthInput(row) = (row - 1) * r;
      lengthOutput(row) = (rows - row) * r ;
    else
      lengthInput(row) = (rows - row) * r ;
      lengthOutput(row) = (row - 1) * r ;
    end
  end
  lengthInput = lengthInput - min(lengthInput);
  lengthOutput = lengthOutput - min(lengthOutput);
else                      % Individual S-Bends
  lengthInput = zeros(rows, 1);
  lengthOutput = lengthInput;
  verticalOffsets = meanVerticalOffset;
end

return



function [lengthCenter, arcAngle] = CalculateAngleAndLength(len, r, rows, lengthInput, lengthOutput, verticalOffsets)

lengthCenter = len - (lengthInput + lengthOutput);

if(any(lengthCenter < 0))
  error('Your s-bend length is too short.');
end

arcAngle = zeros(rows, 1);
for row = 1 : rows
  guideVerticalOffset = abs(verticalOffsets(row));
  if(guideVerticalOffset > 1e-3)
    guideLength = lengthCenter(row);
    fun = @(x) (guideVerticalOffset - 2 * r * (1 - cos(x))) .* cot(x) + 2 * r * sin(x) - guideLength;
    arcAngle(row, 1) = NaN;
    range = 0.5;
    while(isnan(arcAngle(row, 1)))
      arcAngle(row, 1) = funSolve(fun, 0, range * pi);   % Transcendant equation numerical solution
      range = range / 100;
    end
  end
end

nonNull = arcAngle~= 0;
lengthCenter(nonNull) = (abs(verticalOffsets(nonNull)) - 2 * r * (1 -  cos(arcAngle(nonNull)))) ./ sin(arcAngle(nonNull));
arcAngle = sign(verticalOffsets) .* arcAngle * 180/ pi;

return
