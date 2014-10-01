function [struct,infoout1, infoout2,ybranchinfo] = PlaceYbranch(struct, info, inputport, dy, refname, filename)

% Place a 3 port device gds. inputport is label 1, 2 or 3.
% 1 is considered at 0,0 while the y branch is oriented in the +x
% direction. Port 2 and 3 are the positive and negative (y axis) port. dy
% is the distance between these two ports
% Note, infoout1 is always on the other side of the y branch

if(size(info.pos,1) ~= length(info.ori))
    error('size of info.pos must be the same as info.ori');    
end
infoout1 = info;
infoout2 = info;

ybranchinfo = load(filename(1:end-4));
ybranchinfo = ybranchinfo.cells.Ybranch.floorplan;

for ii = 1 : length(info.ori)
    
    if inputport == 1
                
        strans.angle = info.ori(ii);
        struct = add_ref(struct, refname, 'xy', info.pos(ii,:), 'strans', strans);
        
        infoout1loc = SplitInfo(info, ii);        
        infoout2loc = StransInfo(infoout1loc, RotTransXY([ybranchinfo.size(1),-dy/2],[0,0], infoout1loc.ori) , []);
        infoout1loc = StransInfo(infoout1loc, RotTransXY([ybranchinfo.size(1),dy/2],[0,0], infoout1loc.ori), []);
        infoout1.pos(ii,:) = infoout1loc.pos;
        infoout2.pos(ii,:) = infoout2loc.pos;
        
    elseif inputport==2
        
        strans.angle = info.ori(ii)+180;
        struct = add_ref(struct, refname, 'xy', info.pos(ii,:)+RotTransXY([ybranchinfo.size(1),dy/2], [0,0], info.ori(ii)), 'strans', strans);

        infoout1loc = SplitInfo(info, ii);                
        infoout1loc = StransInfo(infoout1loc, RotTransXY([ybranchinfo.size(1),dy/2],[0,0], infoout1loc.ori), []) ;       
        
        infoout2loc = SplitInfo(info, ii);
        infoout2loc = StransInfo(infoout2loc, RotTransXY([0,dy],[0,0], infoout1loc.ori) , []);
        

        infoout1.pos(ii,:) = infoout1loc.pos;
        infoout2.pos(ii,:) = infoout2loc.pos;
        infoout2.ori(ii,:) = infoout2loc.ori + 180;
        
    elseif inputport==3
        
        strans.angle = info.ori(ii)+180;
        struct = add_ref(struct, refname, 'xy', info.pos(ii,:)+RotTransXY([ybranchinfo.size(1),-dy/2], [0,0], info.ori(ii)), 'strans', strans);

        infoout1loc = SplitInfo(info, ii);
        infoout1loc = StransInfo(infoout1loc, RotTransXY([ybranchinfo.size(1),-dy/2],[0,0], infoout1loc.ori), []);
        
        infoout2loc = SplitInfo(info, ii);
        infoout2loc = StransInfo(infoout2loc, RotTransXY([0,-dy],[0,0], infoout1loc.ori) , []);
        
        
        infoout1.pos(ii,:) = infoout1loc.pos;
        infoout2.pos(ii,:) = infoout2loc.pos;
        infoout2.ori(ii,:) = infoout2loc.ori + 180;

    end


end

end