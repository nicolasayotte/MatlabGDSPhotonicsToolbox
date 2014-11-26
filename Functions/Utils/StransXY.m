function xy = StransXY(xy, pos, strans)
%STRANSXY Transform a set of 2D coordinates then translate them
%
%     xy : is (n,2) array of (x,y) points
%     strans : transformation struct with fields 'reflect' and 'angle'
%     pos : translation
%
%     See also ROTTRANSXY

if(isfield(strans, 'reflect'))
  if(strans.reflect)
    xy(:,2) = -xy(:,2);
  end
end

if(isfield(strans, 'angle'))
  xy = RotTransXY(xy, pos, strans.angle);
else
  xy = RotTransXY(xy, pos, 0);
end
