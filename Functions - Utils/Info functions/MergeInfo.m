function info = MergeInfo(varargin)
%MERGEINFO Merge any number of cursor information structures together into one.
% 
%     See also CURSORINFO, INVERTINFO, SPLITINFO, STRANSINFO, WIDTHINFO.

if(nargin > 0)
  info = struct('pos', [], 'ori', [], 'length', [], 'neff', []);
  info = orderfields(info);
  cols = size(varargin{1}.neff, 2);
  info.neff = varargin{1}.neff;
  
  for arg = 1 : nargin
    
    rows = size(varargin{arg}.pos, 1);
    info.pos(end + (1 : rows), :) = varargin{arg}.pos;
    info.ori(end + (1 : rows), 1) = varargin{arg}.ori;
    
    if(isempty(varargin{arg}.length)); varargin{arg}.length = zeros(rows, cols); end
    info.length(end + (1 : rows), 1 : cols) = varargin{arg}.length;
    
    if(~all(varargin{arg}.neff == info.neff))
      error('The neff field of all info variables have to be the same');
    end
    
  end
  
end