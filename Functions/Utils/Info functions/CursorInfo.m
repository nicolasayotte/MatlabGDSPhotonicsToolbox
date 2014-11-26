function info = CursorInfo(pos, ori, neff, varargin)
%CURSORINFO Create a cursor information structure.
%
%     That structure contains position and orientation vectorial information for one
%     or many cursors. If effective indices of modes are listed (column vector), the
%     cumulated length for all these modes will be calculated in the field 'length'.
%
%     info = CursorInfo([0, 0], 90, [1, 2.7]);
%
%     Creates a cursor at the point (0, 0) pointing upwards and will cumulate the
%     the physical length and the optical length for a mode of index 2.7.
% 
%     info = CursorInfo(cumsum(repmat([0, 10]), 5, 1)), 0, 1);
% 
%     Create five cursors at the points on x = 0 and y = 10, 20, 30, 40 and 50 pointing
%     westward will only cumulate the physical lengths travelled.
%
%     See also CURSORINFO, MERGEINFO, SPLITINFO, STRANSINFO, WIDTHINFO, PLACERECT, 
%     PLACEARC, PLACESBEND, PLACESTRUCTURE, PLACETAPER, PLACEMICRORING.


%% Argument Validation
rows = size(pos, 1);
cols = size(neff, 2);
ori = NumberOfRows(rows, ori);
ori = NumberOfColumns(1, ori);
pos = NumberOfColumns(2, pos);


%% Structure creation
info = struct(...
  'pos', pos, ...
  'ori', ori, ...
  'neff', neff, ...
  'length', zeros(rows, cols));


if(nargin > 3)
  args.length = zeros(rows, cols);
  args = ReadOptions(args, varargin);        % Receive a possible length override
  
  % Verify that override size
  [args.length] = NumberOfRows(rows, args.length);
  [args.length] = NumberOfColumns(cols, args.length);
  info.length = args.length;
  info = orderfields(info);
end