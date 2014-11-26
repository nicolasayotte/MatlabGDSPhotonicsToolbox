function [struct, info] = PlaceRef(struct, info, refname)
%PLACEREF places a reference
%Author : Nicolas Ayotte                                   Creation date : 28/11/2014
% 
%     ARGUMENT NAME     SIZE        DESCRIPTION
%     refname           1           cell name
%
%     See also PlaceArc, PlaceTaper, PlaceSBend, PlaceARef

rows = size(info.pos, 1);

for row = 1 : rows
   strans.angle = info.ori(row);
   struct = add_ref(struct, refname, 'xy', info.pos(row,:), 'strans', strans);
   info.ori(row) = ConstrainAngle(info.ori(row) + 180);
end

end