function info = CloneInfo(info, number, forward, upward, ori)
%CLONEINFO Duplicates, moves and rotates cursor information
% 
%     See also CURSORINFO, INVERTINFO, MERGEINFO, SPLITINFO, WIDTHINFO.

info = orderfields(info);

rows = size(info.pos, 1);
[forward, upward, ori] = NumberOfRows(rows, forward, upward, ori);
tmove = [forward, upward];

move = zeros(number * rows, 2);
ori = repmat(ori, number, 1);

for ii = 1 : number
   move((ii - 1) * rows + (1:rows), 1:2) = (ii - 1) * tmove;
end
move = RotTransXY(move, [0,0], repmat(info.ori, number, 1));

info.pos = repmat(info.pos, number, 1) + move;
info.ori = ConstrainAngle(repmat(info.ori, number, 1) + ori);
info.length = repmat(info.length, number, 1) * 0;

end

