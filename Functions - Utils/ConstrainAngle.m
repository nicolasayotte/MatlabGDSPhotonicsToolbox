function varargout = ConstrainAngle(varargin)
%CONSTRAINANGLE Force an angle in degrees to be between -180 and 180 in value.

for whichArg = 1 : nargin
  varargin{whichArg} = mod(varargin{whichArg} + 180, 360) - 180;
end
varargout = varargin;

end