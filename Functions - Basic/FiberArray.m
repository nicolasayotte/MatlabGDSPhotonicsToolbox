function fiberArray = FiberArray(fiberSpacing, horizontalDistance, verticalDistance, couplerLength, couplerWidth, safetyLength)

%FIBERARRAY Create a fiber array information structure
%Author : Nicolas Ayotte                                   Creation date : 26/03/2014
% 
%     fiberArray = FiberArray(fiberSpacing, horizontalDistance, verticalDistance, 
%     couplerLength, couplerWidth, safetyLength)
%
% 
%     FIELD NAME     SIZE        DESCRIPTION
%     'sp'           1           inter-fiber spacing
%     'dx'           1           desired horizontal distance between couplers
%     'dy'           1           desired vertical distance between couplers
%     'len'          1           coupler length
%     'w'            1           coupler width
%     'safety'       1           minimal straight section length after the coupler
% 
%     See also Taper, Waveguide

fiberArray = struct(...
  'sp', fiberSpacing, ...
  'dx', horizontalDistance, ...
  'dy', verticalDistance, ...
  'len', couplerLength, ...
  'w', couplerWidth, ...
  'safety', safetyLength);

end
