function [structure, info, infoInput, len] = PlaceSBend(structure, info, len, h, r, wid, layer, datatype, varargin)
%PlaceSBend places s-bend polygons in a gds structure
%Author : Nicolas Ayotte                                     Creation date : 2/2/2014
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
%     'distance'        m - 1 x 1   [] relative guide spacing at the output
%     'minDistance'     1           [0] minimum waveguide distance in the middle section
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
options.group = false;
options.distance = [];
options.minDistance = 0;
options.align = 'center';
options.type = 'cladding';
options.minimumLength = false;
options.backgroundRect = false;
options = ReadOptions(options, varargin{ : });


%% Argument validation
NonNegative(len, wid);
[len, wid, layer, datatype, info.ori] = NumberOfRows(rows, len, wid, layer, datatype, info.ori);
if(options.group && (rows > 1) && ~isempty(options.distance))
   options.distance = NumberOfColumns(rows - 1, options.distance);
end
wid = NumberOfColumns(cols, wid);
infoInput = InvertInfo(info);

if(options.group && rows > 1)
   info = CheckParallelAndNormal(info);
end


%% Group Routing
[verticalOffsets, lengthInput, lengthOutput] = CalculateOffsets(options, h, r, rows, info);

if options.minimumLength
   len(:) = 2 * r;
   if(options.group && (rows > 1))
      tm = abs(verticalOffsets) > 1e-8;
      if(~isempty(tm))
         len(tm) = lengthInput(tm) + lengthOutput(tm) + 2 * r;
         len(~tm) = max(len);
      end
   end
end

[lengthCenter, arcAngle] = CalculateAngleAndLength(len, r, rows, lengthInput, lengthOutput, verticalOffsets);


%% S-bend
[structure, info] = PlaceRect(structure, info, lengthInput, wid, layer, datatype);
[structure, info] = PlaceArc(structure, info, arcAngle, r, wid, layer, datatype, 'type', options.type);
[structure, info] = PlaceRect(structure, info, lengthCenter, wid, layer, datatype);
[structure, info] = PlaceArc(structure, info, -arcAngle, r, wid, layer, datatype, 'type', options.type);
[structure, info] = PlaceRect(structure, info, lengthOutput, wid, layer, datatype);


%% Background Rect
if(options.backgroundRect && options.group && strcmp(options.type, 'cladding'))
   infoInv = InvertInfo(info);
   infoBG = SplitInfo(infoInput, 1);
   
   normalVector = [cosd(infoInv.ori(1) + 90), sind(infoInv.ori(1) + 90)];
   parVector = [cosd(infoInput.ori(1)), sind(infoInput.ori(1))];
   
   normalPositions = sum([infoInv.pos; infoInput.pos] .* repmat(normalVector, size(infoInput.pos, 1) * 2, 1), 2);
   
   widBG = max(normalPositions) - min(normalPositions) + max(wid(1, :));
   posBG = (max(normalPositions) + min(normalPositions))/2;
   infoBG.pos = normalVector * posBG + sum(infoInv.pos(1,:) .* parVector) .* parVector;
   [structure] = PlaceRect(structure, infoBG, len(1), widBG, layer(1,2:2:end), datatype(1,2:2:end));
end

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
   minLength = r + sbend.minDistance;
   for row = 1 : rows
      if(abs(verticalOffsets(row)) < 1e-8)
         lengthInput(row) = 0;
         lengthOutput(row) = 0;
      elseif(verticalOffsets(row) < 0)
         lengthInput(row) = (row - 1) * minLength;
         lengthOutput(row) = (rows - row) * minLength;
      else
         lengthInput(row) = (rows - row) * minLength;
         lengthOutput(row) = (row - 1) * minLength;
      end
   end
   lengthInput = lengthInput - min(lengthInput);
   lengthOutput = lengthOutput - min(lengthOutput);
   
else  % Individual S-Bends
   lengthInput = zeros(rows, 1);
   lengthOutput = lengthInput;
   verticalOffsets =  ones(rows, 1) * meanVerticalOffset;
end

return



function [lengthCenter, arcAngle] = CalculateAngleAndLength(len, r, rows, lengthInput, lengthOutput, verticalOffsets)

lengthCenter = len - (lengthInput + lengthOutput);

% if(any(lengthCenter < 0))
%    error('Your s-bend length is too short.');
% end

arcAngle = zeros(rows, 1);
for row = 1 : rows
   guideVerticalOffset = abs(verticalOffsets(row));
   if(guideVerticalOffset > 1e-3)
      guideLength = lengthCenter(row);
      fun = @(x) (guideVerticalOffset - 2 * r * (1 - cos(x))) .* cot(x) + 2 * r * sin(x) - guideLength;
      arcAngle(row, 1) = NaN;
      range = 0.5;
      for ii = 1 : 6
         arcAngle(row, 1) = funSolve(fun, 0, range * pi);   % Transcendant equation numerical solution
         if (~isnan(arcAngle(row, 1))); break; end
         range = range / 100;         
      end
   end
end

nonNull = arcAngle~= 0;
lengthCenter(nonNull) = (abs(verticalOffsets(nonNull)) - 2 * r * (1 -  cos(arcAngle(nonNull)))) ./ sin(arcAngle(nonNull));
arcAngle = sign(verticalOffsets) .* arcAngle * 180/ pi;

return