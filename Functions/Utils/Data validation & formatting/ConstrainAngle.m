function varargout = ConstrainAngle(varargin)
%CONSTRAINANGLE Force an angle in degrees to be between -180 and 180 in value.
varargout = cellfun(@(x) mod(x + 180, 360) - 180, varargin, 'UniformOutput', false);
end