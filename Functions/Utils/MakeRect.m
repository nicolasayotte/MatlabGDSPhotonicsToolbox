function outrect = MakeRect(xy, rectsize, varargin)
%MAKERECT Create a 5-points closed polygon from a position xy and a
% size(width, height)
%
%
%     OPTION NAME       SIZE        DESCRIPTION
%     'margin'          1 x 1       .left = [0] left margin
%                                   .right = [0] right margin
%                                   .top = [0] top margin
%                                   .bottom = [0] bottom margin
%
%     See also


options.margin = struct('left', 0, 'right', 0, 'top', 0, 'bottom', 0);
options = ReadOptions(options, varargin{:});

outrect = repmat(xy, 5, 1) + [0, 0; rectsize(1), 0; rectsize; 0, rectsize(2); 0, 0] +...
  [options.margin.left, options.margin.bottom;...
  -options.margin.right, options.margin.bottom;...
  -options.margin.right, -options.margin.top;...
  options.margin.left, -options.margin.top;...
  options.margin.left, options.margin.bottom];

end