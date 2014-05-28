function NonNegative(varargin)
%NONNEGATIVE Ensure that no element of any arrays sent as input arguments have a
% negative value
% 
%     See also EQUAL, NUMBEROFCOLUMNS, NUMBEROFROWS.

for whichArg = 1 : nargin
  if(any(varargin{whichArg} < -1e-6))
    error('ArgCheck:NegativeValues', 'Negative values in argument %s are not supported', inputname(whichArg));
  end
end

end