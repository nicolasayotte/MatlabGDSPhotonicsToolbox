function info = StransInfo(info, pos, strans)
%STRANSINFO Reflects and rotates cursor information.
% 
%     See also CURSORINFO, INVERTINFO, MERGEINFO, SPLITINFO, WIDTHINFO.

info = orderfields(info);
info.pos = StransXY(info.pos, pos, strans);

if(isfield(strans, 'reflect'))
  if(strans.reflect)
    info.ori = -info.ori;
  end
end

if(isfield(strans, 'angle'))
  info.ori = info.ori + strans.angle;
end

