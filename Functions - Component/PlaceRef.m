function [struct, info] = PlaceRef(struct, info, refname)

if(size(info.pos,1) ~= length(info.ori))
error('size of info.pos must be the same as info.ori');    
end

for ii = 1 : length(info.ori)
    strans.angle = info.ori(ii);
    struct = add_ref(struct, refname, 'xy', info.pos(ii,:), 'strans', strans);
    info.ori(ii) = ConstrainAngle(info.ori(ii) + 180);
end

end