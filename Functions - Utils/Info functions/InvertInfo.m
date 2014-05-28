function oinfo = InvertInfo(info)
%INVERTINFO Invert the orientation of all the cursors and reset the lengths
% 
%     See also CURSORINFO, MERGEINFO, SPLITINFO, STRANSINFO, WIDTHINFO.

info = orderfields(info);
oinfo = info;
oinfo.ori = ConstrainAngle(180 + oinfo.ori);
oinfo.length = 0 * oinfo.length;

end