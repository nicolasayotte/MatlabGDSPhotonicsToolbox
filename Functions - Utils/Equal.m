function Equal(varargin)
%EQUAL Verify independently for each array if all their elements have the same value
% 
%     See also NONNEGATIVE, NUMBEROFCOLUMNS, NUMBEROFROWS

for whichArg = 1 : nargin
  if(any(varargin{whichArg} - varargin{whichArg}(1)))
    error('ArgCheck:Equal', 'All values of the array %s must be the same', inputname(whichArg));
  end
end

end