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
%
%     See also TAPER, PLACERECT, PLACEARC, PLACESBEND


rows = size(info.pos, 1);

% Read options
taper = ReadOptions(taper, varargin{ : });

% Parameter validation
NonNegative(len);
[len, taper, info.ori] = NumberOfRows(rows, len, taper, info.ori);
infoInput = InvertInfo(info);


%% Taper element
infoOut = cell(rows, 1);
for row = 1 : rows
  tinfo = SplitInfo(info, row);
  if(taper(row).invert)
    [structure, tinfo] = PlaceRect(structure, tinfo, len(row), taper(row).w2, taper(row).layer, taper(row).dtype , 'offset', taper(row).offset, 'endwidth', taper(row).w1);
  else
    [structure, tinfo] = PlaceRect(structure, tinfo, len(row), taper(row).w1, taper(row).layer, taper(row).dtype , 'offset', taper(row).offset, 'endwidth', taper(row).w2);
  end
  infoOut{row} = tinfo;
end

info = MergeInfo(infoOut{ : });