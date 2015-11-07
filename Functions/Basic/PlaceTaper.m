function [structure, info, infoInput] = PlaceTaper(structure, info, taper, len, varargin)

%PLACETAPER places taper polygons in a gds structure
%Author : Nicolas Ayotte                                   Creation date : 28/11/2013
%
%     This function receives an input GDS structure and the parameters for one or
%     many tapers to create and place at positions and orientations determined by the
%     info variable. It then updates info to the output positions.
%
%     [struct, info] = PlaceTaper(struct, len, taper, info, varargin)
%
%     ARGUMENT NAME     SIZE        DESCRIPTION
%     len               m|1 x 1     taper length
%     taper             m|1 x 1     taper structure
%     info.pos          m x 2       current position
%     info.ori          m|1 x 1     orientation angle in degrees
%     infoInput.pos     m x 2       input position
%     infoInput.ori     m|1 x1      inverse of input orientation
% 
%     OPTION NAME       SIZE        DESCRIPTION
%     'offset'          m|1 x 1     vertical offset of output
%     'invert'          m|1 x 1     invert the taper
%     'group'           1           [false] establish a group
%     'distance'        m-1|1 x 1   [] inter-taper distance
%     'type'            m-1|1 x 1   ['normal'] default taper type
%                                   'movement' no polygons placement, no length
%
%     See also TAPER, PLACERECT, PLACEARC, PLACESBEND


rows = size(info.pos, 1);

% Read options
taper = ReadOptions(taper, varargin{ : });

% Parameter validation
NonNegative(len);
[len, taper, info.ori] = NumberOfRows(rows, len, taper, info.ori);
infoInput = InvertInfo(info);

if(taper(1).group && rows > 1)
   [info, originalOrder, spacing] = CheckParallelAndNormal(info);
   
   if(~isempty(taper(1).distance))
      tdist = NumberOfColumns(rows - 1, taper(1).distance);
      spaceChange =  cumsum([0; tdist' - diff(spacing)]);
      spaceChange = spaceChange - mean(spaceChange);
      for row = 1 : rows
         taper(row).offset = taper(row).offset + spaceChange(row);
      end
   end
end


%% Taper element
infoOut = cell(rows, 1);
for row = 1 : rows
   tinfo = SplitInfo(info, row);
   if(strcmp(taper(row).type, 'movement'))
      taper(row).w1 = taper(row).w1 * 0;
      taper(row).w2 = taper(row).w2 * 0;
   end
  if(taper(row).invert)
    [structure, tinfo] = PlaceRect(structure, tinfo, len(row), taper(row).w2, taper(row).layer, taper(row).dtype , 'offset', taper(row).offset, 'endwidth', taper(row).w1);
  else
    [structure, tinfo] = PlaceRect(structure, tinfo, len(row), taper(row).w1, taper(row).layer, taper(row).dtype , 'offset', taper(row).offset, 'endwidth', taper(row).w2);
  end
  infoOut{row} = tinfo;
end

info = MergeInfo(infoOut{ : });

if(taper(1).group && rows > 1)
   info = SplitInfo(info, originalOrder);  % Put info back in its original order
end

end