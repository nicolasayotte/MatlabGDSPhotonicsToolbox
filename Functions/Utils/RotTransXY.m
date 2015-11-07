function xy = RotTransXY(xy, pos, ori)
%ROTTRANSXY rotates a set of 2D coordinates then translates them
%
%     ARGUMENT NAME     SIZE        DESCRIPTION
%     xy                n x 2       array of  points [x, y] OR
%     xy                1 x m       cell array of arrays of points n x 2
%     ori               1           rotation angle
%     pos               1 x 2       translation
%
%     See also STRANSXY

if(iscell(xy))
   if(exist('RotTransXYCell.mexw64', 'file') || exist('RotTransXYCell.mexw32', 'file'))
      xy = RotTransXYCell(xy, pos, ori);
   else
      xy = cellfun(@(x)RotTransXY(x, pos, ori), xy, 'UniformOutput', false);
   end
else
   xy = [xy(:,1) .* cosd(ori) - xy(:,2) .* sind(ori) + pos(1), xy(:,1) .* sind(ori) + xy(:,2) .* cosd(ori) + pos(2)];
end

end