function oinfo = SplitInfo(info, indices)
%SPLITINFO Separates certain indices from a cursor information structure.
% 
%     See also CURSORINFO, INVERTINFO, MERGEINFO, STRANSINFO, WIDTHINFO.

info = orderfields(info);
oinfo.pos = info.pos(indices, :);
oinfo.ori = info.ori(indices);
oinfo.length = info.length(indices, :);
oinfo.neff = info.neff;

end