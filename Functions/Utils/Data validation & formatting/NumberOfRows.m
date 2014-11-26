function varargout = NumberOfRows(rows, varargin)
%NUMBEROFROWS makes sure that each array sent in as arguments has the number of
% rows specified by rows. If the number of rows is 1 then the matrix is
% replicated to make it compliant to the rule.
%
%     See also NUMBEROFCOLUMNS, EQUAL, NONNEGATIVE.


for whichArg = 1 : nargin - 1
  arg = varargin{whichArg};
  if((size(arg, 1) == 1) && size(arg, 1) < rows)
    varargin{whichArg} = repmat(arg, rows, 1);
  elseif((size(arg, 1) ~= rows) && ~isempty(arg))
    error('ArgCheck:NumberOfRows', 'Number of rows in argument %s is not consistent', inputname(whichArg + 1));
  end
end
varargout = varargin;

end