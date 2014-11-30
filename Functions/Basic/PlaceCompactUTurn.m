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
options.switch = false; % swith the waveguide entrance (1 or -1)
options.phWcurve = phW; % phWcurve = Waveguide charactereristic of the curved sections (for doping characterization). No tapers are included
options = ReadOptions(options, varargin{:});


%% Argument validation
[info, ~, spacing] = CheckParallelAndNormal(info);

if (any(diff(spacing) - phW.sp * 2 > 1e-10))
   error('The spacing between the waveguide infos must be twice the waveguide spacing parameter.');
end

if options.phWcurve.r ~= phW.r
    error('The radius of curvature of phWcurve must be the same as phW')
end

infoIn = InvertInfo(info);


%% Place Uturn
switch options.side
   case 'bottom'
       if options.switch
           
           lenBottom = cumsum(repmat(2 * phW.r + phW.sp, rows, 1)) - (2 * phW.r + phW.sp);
           bottomInfo = info;
           
           [structure, bottomInfo] = PlaceRect(structure, bottomInfo, lenBottom, phW.w, phW.layer, phW.dtype);
           [structure, bottomInfo] = PlaceArc(structure, bottomInfo, -90, options.phWcurve.r, options.phWcurve.w, options.phWcurve.layer, options.phWcurve.dtype);
           [structure, bottomInfo] = PlaceArc(structure, bottomInfo, 180, options.phWcurve.r, options.phWcurve.w, options.phWcurve.layer, options.phWcurve.dtype);
           [structure, bottomInfo] = PlaceRect(structure, bottomInfo, phW.sp, phW.w, phW.layer, phW.dtype);
           [structure, bottomInfo] = PlaceArc(structure, bottomInfo, 90, options.phWcurve.r, options.phWcurve.w, options.phWcurve.layer, options.phWcurve.dtype);
           [structure, bottomInfo] = PlaceRect(structure, bottomInfo, lenBottom + 2 * phW.r, phW.w, phW.layer, phW.dtype);
           
           infoOut = bottomInfo;
       else
           lenBottom = cumsum(repmat(2 * phW.r + phW.sp, rows, 1)) - phW.sp;
           bottomInfo = info;
           
           [structure, bottomInfo] = PlaceRect(structure, bottomInfo, lenBottom, phW.w, phW.layer, phW.dtype);
           [structure, bottomInfo] = PlaceArc(structure, bottomInfo, -90, options.phWcurve.r, options.phWcurve.w, options.phWcurve.layer, options.phWcurve.dtype);
           [structure, bottomInfo] = PlaceRect(structure, bottomInfo, phW.sp, phW.w, phW.layer, phW.dtype);
           [structure, bottomInfo] = PlaceArc(structure, bottomInfo, -180, options.phWcurve.r, options.phWcurve.w, options.phWcurve.layer, options.phWcurve.dtype);           
           [structure, bottomInfo] = PlaceArc(structure, bottomInfo, 90, options.phWcurve.r, options.phWcurve.w, options.phWcurve.layer, options.phWcurve.dtype);
           [structure, bottomInfo] = PlaceRect(structure, bottomInfo, lenBottom - 2 * phW.r, phW.w, phW.layer, phW.dtype);
           
           infoOut = bottomInfo;
       end
   case 'center'
       if options.switch
           lenBottom = cumsum(repmat(2 * phW.r + phW.sp, rows - floor(rows/2), 1))- phW.sp;
           bottomInfo = SplitInfo(info, 1 : floor(rows/2));
           
           [structure, bottomInfo] = PlaceRect(structure, bottomInfo, lenBottom, phW.w, phW.layer, phW.dtype);
           [structure, bottomInfo] = PlaceArc(structure, bottomInfo, -90, options.phWcurve.r, options.phWcurve.w, options.phWcurve.layer, options.phWcurve.dtype);
           [structure, bottomInfo] = PlaceRect(structure, bottomInfo, phW.sp, phW.w, phW.layer, phW.dtype);
           [structure, bottomInfo] = PlaceArc(structure, bottomInfo, -180, options.phWcurve.r, options.phWcurve.w, options.phWcurve.layer, options.phWcurve.dtype);           
           [structure, bottomInfo] = PlaceArc(structure, bottomInfo, 90, options.phWcurve.r, options.phWcurve.w, options.phWcurve.layer, options.phWcurve.dtype);
           [structure, bottomInfo] = PlaceRect(structure, bottomInfo, lenBottom- 2 * phW.r, phW.w, phW.layer, phW.dtype);
       else
           lenBottom = cumsum(repmat(2 * phW.r + phW.sp, floor(rows/2), 1)) - (2 * phW.r + phW.sp);
           bottomInfo = SplitInfo(info, 1 : floor(rows/2));
           
           [structure, bottomInfo] = PlaceRect(structure, bottomInfo, lenBottom, phW.w, phW.layer, phW.dtype);
           [structure, bottomInfo] = PlaceArc(structure, bottomInfo, -90, options.phWcurve.r, options.phWcurve.w, options.phWcurve.layer, options.phWcurve.dtype);
           [structure, bottomInfo] = PlaceArc(structure, bottomInfo, 180, options.phWcurve.r, options.phWcurve.w, options.phWcurve.layer, options.phWcurve.dtype);
           [structure, bottomInfo] = PlaceRect(structure, bottomInfo, phW.sp, phW.w, phW.layer, phW.dtype);
           [structure, bottomInfo] = PlaceArc(structure, bottomInfo, 90, options.phWcurve.r, options.phWcurve.w, options.phWcurve.layer, options.phWcurve.dtype);
           [structure, bottomInfo] = PlaceRect(structure, bottomInfo, lenBottom + 2 * phW.r, phW.w, phW.layer, phW.dtype);

       end
       
       if options.switch           
           lenTop = flipud(cumsum(repmat(2 * phW.r + phW.sp, floor(rows/2), 1)) - (2 * phW.r + phW.sp));
           topInfo = SplitInfo(info, 1 + floor(rows/2) : rows);
           
           [structure, topInfo] = PlaceRect(structure, topInfo, lenTop, phW.w, phW.layer, phW.dtype);
           [structure, topInfo] = PlaceArc(structure, topInfo, 90, options.phWcurve.r, options.phWcurve.w, options.phWcurve.layer, options.phWcurve.dtype);
           [structure, topInfo] = PlaceArc(structure, topInfo, -180, options.phWcurve.r, options.phWcurve.w, options.phWcurve.layer, options.phWcurve.dtype);
           [structure, topInfo] = PlaceRect(structure, topInfo, phW.sp, phW.w, phW.layer, phW.dtype);
           [structure, topInfo] = PlaceArc(structure, topInfo, -90, options.phWcurve.r, options.phWcurve.w, options.phWcurve.layer, options.phWcurve.dtype);
           [structure, topInfo] = PlaceRect(structure, topInfo, lenTop + 2 * phW.r, phW.w, phW.layer, phW.dtype);%
       else
           lenTop = flipud(cumsum(repmat(2 * phW.r + phW.sp, rows - floor(rows/2), 1))) - phW.sp;
           topInfo = SplitInfo(info, 1 + floor(rows/2) : rows);
           
           [structure, topInfo] = PlaceRect(structure, topInfo, lenTop, phW.w, phW.layer, phW.dtype);
           [structure, topInfo] = PlaceArc(structure, topInfo, 90, options.phWcurve.r, options.phWcurve.w, options.phWcurve.layer, options.phWcurve.dtype);
           [structure, topInfo] = PlaceRect(structure, topInfo, phW.sp, phW.w, phW.layer, phW.dtype);
           [structure, topInfo] = PlaceArc(structure, topInfo, 180, options.phWcurve.r, options.phWcurve.w, options.phWcurve.layer, options.phWcurve.dtype);
           [structure, topInfo] = PlaceArc(structure, topInfo, -90, options.phWcurve.r, options.phWcurve.w, options.phWcurve.layer, options.phWcurve.dtype);
           [structure, topInfo] = PlaceRect(structure, topInfo, lenTop - 2 * phW.r, phW.w, phW.layer, phW.dtype);
       end
       
       infoOut = MergeInfo(topInfo, bottomInfo);         
     
   case 'top'
       if options.switch      
           lenTop = flipud(cumsum(repmat(2 * phW.r + phW.sp, rows, 1))) - 3*phW.sp;
           topInfo = info;
           
           [structure, topInfo] = PlaceRect(structure, topInfo, lenTop, phW.w, phW.layer, phW.dtype);
           [structure, topInfo] = PlaceArc(structure, topInfo, 90, options.phWcurve.r, options.phWcurve.w, options.phWcurve.layer, options.phWcurve.dtype);
           [structure, topInfo] = PlaceArc(structure, topInfo, -180, options.phWcurve.r, options.phWcurve.w, options.phWcurve.layer, options.phWcurve.dtype);
           [structure, topInfo] = PlaceRect(structure, topInfo, phW.sp, phW.w, phW.layer, phW.dtype);
           [structure, topInfo] = PlaceArc(structure, topInfo, -90, options.phWcurve.r, options.phWcurve.w, options.phWcurve.layer, options.phWcurve.dtype);
           [structure, topInfo] = PlaceRect(structure, topInfo, lenTop + 2 * phW.r, phW.w, phW.layer, phW.dtype);                                 
           infoOut = topInfo;
       else           
           lenTop = flipud(cumsum(repmat(2 * phW.r + phW.sp, rows, 1))) - phW.sp;
           topInfo = info;
           
           [structure, topInfo] = PlaceRect(structure, topInfo, lenTop, phW.w, phW.layer, phW.dtype);
           [structure, topInfo] = PlaceArc(structure, topInfo, 90, options.phWcurve.r, options.phWcurve.w, options.phWcurve.layer, options.phWcurve.dtype);
           [structure, topInfo] = PlaceRect(structure, topInfo, phW.sp, phW.w, phW.layer, phW.dtype);
           [structure, topInfo] = PlaceArc(structure, topInfo, 180, options.phWcurve.r, options.phWcurve.w, options.phWcurve.layer, options.phWcurve.dtype);
           [structure, topInfo] = PlaceArc(structure, topInfo, -90, options.phWcurve.r, options.phWcurve.w, options.phWcurve.layer, options.phWcurve.dtype);
           [structure, topInfo] = PlaceRect(structure, topInfo, lenTop - 2 * phW.r, phW.w, phW.layer, phW.dtype);
           
           infoOut = topInfo;
       end
    otherwise
        error('Option not handled')
end

infoOut = CheckParallelAndNormal(infoOut);

end
