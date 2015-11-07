function [structure, info, infoInput] = PlaceArc(structure, info, ang, r, wid, layer, datatype, varargin)
%PLACEARC places arc polygons in a gds structure
%Author : Nicolas Ayotte                                    Creation date : 2/12/2013
%
%     This function receives an input GDS structure and the parameters for one or many
%     rectangles to create and place at positions and orientations determined by the info
%     variable. It then updates info to the output positions.
%
%     [struct, info] = PlaceArc(struct, r, ang, wid, layer, info)
%     [struct, info, infoInput] = PlaceArc(struct, r, ang, wid, layer, info)
%     [struct, info] = PlaceArc(struct, r, ang, wid, layer, info, 'group', true)
%
%
%     ARGUMENT NAME     SIZE        DESCRIPTION
%     structure         1           gds_structure library object
%     r                 1           bend radius
%     ang               m x 1       bend rotation angle
%     wid               m|1 x n|1   rect widths
%     layer             m|1 x n     target layers
%     datatype          m|1 x n     target datatypes
%     info.pos          m x 2       current position
%     info.ori          m|1 x 1     orientation angle in degrees
%     infoInput.pos     m x 2       input position
%     infoInput.ori     m|1 x 1     inverse of input orientation
%
%     OPTION NAME       SIZE        DESCRIPTION
%     'group'           1           [false] arc as a group switch
%     'distance'        m - 1 x 1   [] guide spacing from the first
%     'type'            string      'normal' all layers turn smoothly
%                                   ['cladding'] even layer indices turn in straight segments
%                                   'metal' all layers turn in straight segments
%                                   'equidistant' maintain interwaveguide distances
%                                   'movement' only moves info, no polygons created
%     'resolution'      1           [30 nm] distance between two points in the curves
%
%     See also PlaceRect, PlaceTaper, PlaceSBend,

rows = size(info.pos, 1);
cols = size(layer, 2);


%% Default values for valid options
options.group = false;
options.distance = [];
options.type = 'normal';
options.resolution = 30e-3;
options.maxVertices = 199;
options = ReadOptions(options, varargin{ : });


%% Arguments validation
NonNegative(wid);
[wid, layer, datatype, ang, info.ori, info.length] = NumberOfRows(rows, wid, layer, datatype, ang, info.ori, info.length);
[wid, datatype] = NumberOfColumns(cols, wid, datatype);

if(options.group && (rows > 1) && ~isempty(options.distance))
  options.distance = NumberOfColumns(rows - 1, options.distance);
  if(strcmp(options.type, 'equidistant'))
    error('Cannot use equidistant type and change inter-waveguide distance at the same time');
  end
end
if(strcmp(options.type, 'movement'))
  wid(:,:) = 0;
end
[info.ori] = ConstrainAngle(info.ori);    % constrain angle to E ]-180, 180]

if(any(r - 0.5 * wid) < 0)
  error('Curving radius must be larger than half the width.');
end
radius = r;

if(options.group && rows > 1)
  [info, originalOrder] = CheckParallelAndNormal(info);
  if(any(ang - ang(1)))
    error('The angles must be the same to be grouped');
  end
end

infoInput = InvertInfo(info);


% Large angles will call the function recursively by increments of 90 degrees
if(abs(ang) > 90)
  remainingAngle = ang - sign(ang) * 90;
  ang = sign(ang) * 90;
  
  if(options.group && rows > 1 && any(options.distance))
    relNormalSpacing = diff(info.pos, 1);
    absNormalSpacing = [0, 0; cumsum(relNormalSpacing, 1)];
    initialDistance = diff(sqrt(sum(absNormalSpacing .* absNormalSpacing, 2)) .* tand(0.5 * ang));
    if(abs(mean(initialDistance)) >= abs(mean(options.distance)))
      varargin{find(cellfun(@(x)strcmp(x, 'distance'), varargin)) + 1} = [];
    else
      options.distance = [];
    end
  end
else
  remainingAngle = 0;
end


%% Group Routing
[inputOffset, outputOffset, initialDistance] = DetermineLengthOffsets(options, ang, rows, info);
[structure, info] = PlaceRect(structure, info, inputOffset, wid, layer, datatype); % Input Length Offset

%% Arc elements
arcEl = {};
for row = 1 : rows
  
  if(strcmp(options.type, 'equidistant'))
    if(sign(ang) == 1)
      radius = r + initialDistance(row);
    else
      radius = r + max(initialDistance) - initialDistance(row);
    end
  end
  
  for col = 1 : cols
    if(wid(row, col) > 0)
      if(~mod(col, 2) && strcmpi(options.type, 'cladding'))   % Cladding treament
        [shortSide, longSide] = MakeCladdingArc(ang, radius, wid, row, col);
        arcxy = [shortSide; longSide(end : -1 : 1, : ); shortSide(1, : )];
        arcxy( : , 2) = arcxy( : , 2) + radius;
      else
        switch options.type
          case 'metal'
            noPtsShortSide = 2;
            noPtsLongSide = 2;
          otherwise
            noPtsShortSide = ceil((radius - 0.5 * wid(row, col)) * pi * abs(ang(row)) / 180 / options.resolution) + 1;         % Number of points on side1
            noPtsLongSide = ceil((radius + 0.5 * wid(row, col)) * pi * abs(ang(row)) / 180 / options.resolution) + 1;         % Number of points on side2
        end
        if((radius - 0.5 * wid(row, col)) < 0)
          noPtsShortSide = 1;
        end
        if(noPtsShortSide + noPtsLongSide + 1 > options.maxVertices)
          nel = ceil((noPtsShortSide + noPtsLongSide + 1 ) / options.maxVertices);
          arcxy = cell(1, nel);
          for el = 1 : nel
            elAng = ang(row) / nel;
            anglesShort = linspace((el - 1) * elAng, el * elAng, noPtsShortSide / nel) - 90;
            anglesLong = linspace((el - 1) * elAng, el * elAng, noPtsLongSide / nel) - 90;
            shortSide = (max([radius - 0.5 * wid(row, col), 0])) * [cosd(anglesShort)', sind(anglesShort)'];
            longSide = (radius + 0.5 * wid(row, col)) * [cosd(anglesLong)', sind(anglesLong)'];
            elArcxy = [shortSide; flipud(longSide); shortSide(1, : )];
            elArcxy( : , 2) = elArcxy( : , 2) + radius;
            arcxy{el} = elArcxy;
          end
        else
          anglesShort = linspace(0, ang(row), noPtsShortSide) - 90;
          anglesLong = linspace(0, ang(row), noPtsLongSide) - 90;
          shortSide = (max([radius - 0.5 * wid(row, col), 0])) * [cosd(anglesShort)', sind(anglesShort)'];
          longSide = (radius + 0.5 * wid(row, col)) * [cosd(anglesLong)', sind(anglesLong)'];
          arcxy = [shortSide; flipud(longSide); shortSide(1, : )];
          arcxy( : , 2) = arcxy( : , 2) + radius;
        end
      end
      arcEl = [arcEl, {gds_element('boundary', 'xy', RotTransXY(arcxy, info.pos(row, : ), ...
        info.ori(row) + 180 * (ang(row) < 0)), 'layer', layer(row, col), 'dtype', datatype(row, col))}];
    end
  end
  
  displacement = sign(ang(row)) * ([-sind(info.ori(row)), cosd(info.ori(row))] - [-sind(info.ori(row) + ang(row)), cosd(info.ori(row) + ang(row))]);
  info.pos(row, : ) = info.pos(row, : ) + radius * displacement;
end

structure = add_element(structure, arcEl);
info.ori = ConstrainAngle(info.ori + ang);  % ori E ]-180, 180]
if(isempty(info.length)); info.length = zeros(rows, length(info.neff)); end
info.length = info.length + repmat(pi * abs(ang) / 180 * radius, 1, length(info.neff)) .* (repmat(info.neff, rows, 1) .* repmat(sum(wid, 2) > 0, 1, size(info.neff, 2)));


[structure, info] = PlaceRect(structure, info, outputOffset, wid, layer, datatype); % Output Length Offset

if(options.group && rows > 1)
  info = SplitInfo(info, originalOrder);  % Put info back in its original order
end

%% If abs(ang) is over 90 degrees, put a other arcs to complete the turn
if (abs(remainingAngle) > 1e-6)
  [structure, info] = PlaceArc(structure, info, remainingAngle, radius, wid, layer, datatype, varargin{ : });
end
end



function [shortSide, longSide] = MakeCladdingArc(ang, r, wid, row, col)
angles = linspace(0, ang(row), 2) - 90; % Angle vector
shortSide = (r - 0.5 * wid(row, col)) * [cosd(angles)', sind(angles)'];
longSide = (r + 0.5 * wid(row, col)) * [cosd(angles)', sind(angles)'];

normStart = abs(tand(ang(row)/2)) * (r + 0.5 * wid(row, col)) * [0, -1];
normEnd = abs(tand(ang(row)/2)) * (r + 0.5 * wid(row, col)) * [cosd(ang(row) - 90), sind(ang(row) - 90)];

if(abs(ang(row)) < 90)
  longSide(4, : ) = longSide(2, : );
  longSide(2, : ) = longSide(1, : ) + normEnd;
  longSide(3, : ) = longSide(4, : ) + normStart;
else
  longSide(3, : ) = longSide(2, : );
  longSide(2, : ) = longSide(1, : ) + normEnd;
end

end



function [lengthIn, lengthOut, distance] = DetermineLengthOffsets(arc, ang, rows, info)
if(arc.group && rows > 1)
  relNormalSpacing = diff(info.pos, 1);
  absNormalSpacing = [0, 0; cumsum(relNormalSpacing, 1)];
  initialDistance = sqrt(sum(absNormalSpacing .* absNormalSpacing, 2)) .* tand(0.5 * ang);
  initialDistance = initialDistance - min(initialDistance);
  distance = sqrt(sum(absNormalSpacing .* absNormalSpacing, 2));
  distance = max(distance) - distance;
else
  distance = zeros(1, rows);
end

if(arc.group && rows > 1 && ~strcmp(arc.type, 'equidistant'))
  if(~isempty(arc.distance))
    finalDistance = [0; cumsum(arc.distance')];
    distanceChangeIn = finalDistance ./sind(ang) - initialDistance ./(1 - cosd(ang));
    distanceChangeOut = cosd(ang) .* -distanceChangeIn;
  else
    distanceChangeIn = 0;
    distanceChangeOut = 0;
  end
  lengthIn = initialDistance + distanceChangeIn;
  lengthIn = max(lengthIn) - lengthIn;
  lengthOut = initialDistance + distanceChangeOut;
  lengthOut = max(lengthOut) - lengthOut;
else
  lengthIn = zeros(rows, 1);
  lengthOut = zeros(rows, 1);
end

end