function [vectorialDistance, absoluteDistance] = RelativeDistanceInfo(info1, info2, varargin)
%RELATIVEDISTANCEINFO returns relative vectorial distance between two cursors
%Author : Alexandre D. Simard                              Creation date : 01/11/2014
% 
%     This function returns the distance along the propagation axis and the normal
%     distance between two cursor information structures.
% 
% 
%     OPTION NAME       SIZE        DESCRIPTION
%     'index'           m           [1, 2] dimensions of distance to output
%                                   1 is along the propagation direction
%                                   2 is normal to that direction
% 
%     See also CURSORINFO, INVERTINFO, SPLITINFO, STRANSINFO, WIDTHINFO.

rows = max([size(info1.pos, 1), size(info2.pos, 1)]);


%% Default value for valid options
options.index = [1,2];
options = ReadOptions(options, varargin{:});


%% Argument validation
if (rows > 1)
    error('There must be a single cursor in each cursor')    
end

if (abs(mod(info1.ori, 180) - mod(info2.ori, 180)) > 1e-9)
    error('The propagation directions must be parallel.')    
end


%% Distance calculations
pos1 = RotTransXY(info1.pos, [0,0], -info1.ori);
pos2 = RotTransXY(info2.pos, [0,0], -info1.ori);

distance = pos1 - pos2;
vectorialDistance = distance(options.index);

if(nargout > 1)
   absoluteDistance = sqrt(distance(1) ^ 2 + distance(2) ^ 2);
end

end