function [struct, infoout1, infoout2, ybranchinfo] = PlaceYBranch(struct, info, inputport, dy, refname, filename)
%PLACEYBRANCH places a y-branch reference
% 
%     Place a 3 port device gds. inputport is label 1, 2 or 3.
%     1 is considered at 0,0 while the y branch is oriented in the + x direction.
%     Port 2 and 3 are the positive and negative (y axis) port. dy
%     is the distance between these two ports
%
%     Note, infoout1 is always on the other side of the y branch

rows = size(info.pos,1);

infoout1 = info;
infoout2 = info;

ybranchinfo = load(filename(1:end-4));
ybranchinfo = ybranchinfo.cells.Ybranch.floorplan;

for row = 1 : rows
   switch inputport
      case 1
        strans.angle = info.ori(row);
        struct = add_ref(struct, refname, 'xy', info.pos(row,:), 'strans', strans);
        
        infoout1loc = SplitInfo(info, row);        
        infoout2loc = StransInfo(infoout1loc, RotTransXY([ybranchinfo.size(1), -dy/2], [0, 0], infoout1loc.ori) , []);
        infoout1loc = StransInfo(infoout1loc, RotTransXY([ybranchinfo.size(1), dy/2], [0, 0], infoout1loc.ori), []);
        infoout1.pos(row,:) = infoout1loc.pos;
        infoout2.pos(row,:) = infoout2loc.pos;
        
      case 2
        strans.angle = info.ori(row)+180;
        struct = add_ref(struct, refname, 'xy', info.pos(row,:)+RotTransXY([ybranchinfo.size(1),dy/2], [0,0], info.ori(row)), 'strans', strans);

        infoout1loc = SplitInfo(info, row);                
        infoout1loc = StransInfo(infoout1loc, RotTransXY([ybranchinfo.size(1),dy/2],[0,0], infoout1loc.ori), []) ;       
        infoout2loc = SplitInfo(info, row);
        infoout2loc = StransInfo(infoout2loc, RotTransXY([0,dy],[0,0], infoout1loc.ori) , []);
        infoout1.pos(row,:) = infoout1loc.pos;
        infoout2.pos(row,:) = infoout2loc.pos;
        infoout2.ori(row,:) = infoout2loc.ori + 180;
        
      case 3
        strans.angle = info.ori(row)+180;
        struct = add_ref(struct, refname, 'xy', info.pos(row,:)+RotTransXY([ybranchinfo.size(1),-dy/2], [0,0], info.ori(row)), 'strans', strans);

        infoout1loc = SplitInfo(info, row);
        infoout1loc = StransInfo(infoout1loc, RotTransXY([ybranchinfo.size(1),-dy/2],[0,0], infoout1loc.ori), []);
        infoout2loc = SplitInfo(info, row);
        infoout2loc = StransInfo(infoout2loc, RotTransXY([0,-dy],[0,0], infoout1loc.ori) , []);
        infoout1.pos(row,:) = infoout1loc.pos;
        infoout2.pos(row,:) = infoout2loc.pos;
        infoout2.ori(row,:) = infoout2loc.ori + 180;

   end
end

end