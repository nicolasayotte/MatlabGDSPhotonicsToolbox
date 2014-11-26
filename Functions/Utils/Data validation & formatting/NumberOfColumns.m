function varargout = NumberOfColumns(cols, varargin)
%NUMBEROFCOLUMNS makes sure that each array sent in as arguments has the number of
% columns specified by cols. If the number of columns is 1 then the matrix is
% replicated to make it compliant to the rule.
%
%     See also NUMBEROFROWS, EQUAL, NONNEGATIVE.

for whichArg = 1 : nargin - 1
  arg = varargin{whichArg};
  if((size(arg, 2) == 1) && size(arg, 2) < cols)
    varargin{whichArg} = repmat(arg, 1, cols);
  elseif((size(arg, 2) ~= cols)  && ~isempty(arg))
    error('ArgCheck:NumberOfColumns', 'Number of columns in argument %u is not consistent\n', inputname(whichArg + 1));
  end
end
varargout = varargin;

end