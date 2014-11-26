function [structure, infoOut, infoIn] = PlaceCompactUTurn(structure, info, phW, varargin)
%PLACECOMPACTUTURN takes a group of waveguides around in a precise and compact u-turn
%Author : Alexandre D. Simard                              Creation date : 01/11/2014
% 
% Place compact uturn array. Info must be in the same orientation, spaced
% by 2*phW.sp. PhW can not be an array
% 
% 
%     OPTION NAME       SIZE        DESCRIPTION
%     'side'            1           ['center'] split turn side at the center
%                                   'bottom' every guide turns towards the bottom
%                                   'top' every guide turns towards the top
% 
%     See also PlaceRect, PlaceArc, PlaceTaper

rows = size(info.pos, 1);


%% Default values for valid options
options.side = 'center';
options = ReadOptions(options, varargin{:});


%% Argument validation
[info, ~, spacing] = CheckParallelAndNormal(info);

if (any(diff(spacing) ~= phW.sp * 2))
   error('The spacing between the waveguide infos must be twice the waveguide spacing parameter.');
end

infoIn = InvertInfo(info);


%% Place Uturn
switch options.side
   case 'bottom'
      lenBottom = cumsum(repmat(2 * phW.r + phW.sp, rows, 1)) - (2 * phW.r + phW.sp);
      bottomInfo = info;
      
      [structure, bottomInfo] = PlaceRect(structure, bottomInfo, lenBottom, phW.w, phW.layer, phW.dtype);
      [structure, bottomInfo] = PlaceArc(structure, bottomInfo, -90, phW.r, phW.w, phW.layer, phW.dtype);
      [structure, bottomInfo] = PlaceArc(structure, bottomInfo, 180, phW.r, phW.w, phW.layer, phW.dtype);
      [structure, bottomInfo] = PlaceRect(structure, bottomInfo, phW.sp, phW.w, phW.layer, phW.dtype);
      [structure, bottomInfo] = PlaceArc(structure, bottomInfo, 90, phW.r, phW.w, phW.layer, phW.dtype);
      [structure, bottomInfo] = PlaceRect(structure, bottomInfo, lenBottom + 2 * phW.r, phW.w, phW.layer, phW.dtype);
      
      infoOut = bottomInfo;
      
   case 'center'
      lenBottom = cumsum(repmat(2 * phW.r + phW.sp, floor(rows/2), 1)) - (2 * phW.r + phW.sp);
      bottomInfo = SplitInfo(info, 1 : floor(rows/2));
      
      [structure, bottomInfo] = PlaceRect(structure, bottomInfo, lenBottom, phW.w, phW.layer, phW.dtype);
      [structure, bottomInfo] = PlaceArc(structure, bottomInfo, -90, phW.r, phW.w, phW.layer, phW.dtype);
      [structure, bottomInfo] = PlaceArc(structure, bottomInfo, 180, phW.r, phW.w, phW.layer, phW.dtype);
      [structure, bottomInfo] = PlaceRect(structure, bottomInfo, phW.sp, phW.w, phW.layer, phW.dtype);
      [structure, bottomInfo] = PlaceArc(structure, bottomInfo, 90, phW.r, phW.w, phW.layer, phW.dtype);
      [structure, bottomInfo] = PlaceRect(structure, bottomInfo, lenBottom + 2 * phW.r, phW.w, phW.layer, phW.dtype);
      
      lenTop = flipud(cumsum(repmat(2 * phW.r + phW.sp, rows - floor(rows/2), 1))) - phW.sp;
      topInfo = SplitInfo(info, 1 + floor(rows/2) : rows);
      
      [structure, topInfo] = PlaceRect(structure, topInfo, lenTop, phW.w, phW.layer, phW.dtype);
      [structure, topInfo] = PlaceArc(structure, topInfo, 90, phW.r, phW.w, phW.layer, phW.dtype);
      [structure, topInfo] = PlaceRect(structure, topInfo, phW.sp, phW.w, phW.layer, phW.dtype);
      [structure, topInfo] = PlaceArc(structure, topInfo, 180, phW.r, phW.w, phW.layer, phW.dtype);
      [structure, topInfo] = PlaceArc(structure, topInfo, -90, phW.r, phW.w, phW.layer, phW.dtype);
      [structure, topInfo] = PlaceRect(structure, topInfo, lenTop - 2 * phW.r, phW.w, phW.layer, phW.dtype);
      
      infoOut = MergeInfo(topInfo, bottomInfo);
      
   case 'top'
      lenTop = flipud(cumsum(repmat(2 * phW.r + phW.sp, rows, 1))) - phW.sp;
      topInfo = info;
      
      [structure, topInfo] = PlaceRect(structure, topInfo, lenTop, phW.w, phW.layer, phW.dtype);
      [structure, topInfo] = PlaceArc(structure, topInfo, 90, phW.r, phW.w, phW.layer, phW.dtype);
      [structure, topInfo] = PlaceRect(structure, topInfo, phW.sp, phW.w, phW.layer, phW.dtype);
      [structure, topInfo] = PlaceArc(structure, topInfo, 180, phW.r, phW.w, phW.layer, phW.dtype);
      [structure, topInfo] = PlaceArc(structure, topInfo, -90, phW.r, phW.w, phW.layer, phW.dtype);
      [structure, topInfo] = PlaceRect(structure, topInfo, lenTop - 2 * phW.r, phW.w, phW.layer, phW.dtype);
      
      infoOut = topInfo;
end

infoOut = CheckParallelAndNormal(infoOut);

end
