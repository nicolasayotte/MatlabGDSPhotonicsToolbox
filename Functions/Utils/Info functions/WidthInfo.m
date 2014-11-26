function width = WidthInfo(info, waveguide)
%WIDTHINFO Returns the total width of the waveguides.
% 
%     See also CURSORINFO, INVERTINFO, MERGEINFO, SPLITINFO, STRANSINFO.

info = CheckParallelAndNormal(info);
relNormalSpacing = diff(info.pos,1);
absNormalSpacing = [0,0; cumsum(relNormalSpacing,1)];
distance = abs(max(sqrt(sum(absNormalSpacing .* absNormalSpacing,2))));
width = distance + max(waveguide.w);

end