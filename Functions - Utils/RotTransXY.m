function xy = RotTransXY(xy, pos, ori)
%ROTTRANSXY rotates a set of 2D coordinates then translates them
% 
%     ARGUMENT NAME     SIZE        DESCRIPTION
%     xy                n x 2       array of  points [x, y]
%     ori               1           rotation angle
%     pos               m x 1       translation
%
%     See also STRANSXY

xy = [xy(:,1) .* cosd(ori) - xy(:,2) .* sind(ori) + pos(1), xy(:,1) .* sind(ori) + xy(:,2) .* cosd(ori) + pos(2)];

end