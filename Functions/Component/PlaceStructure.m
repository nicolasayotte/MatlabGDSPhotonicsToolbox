function [struct, info, infoInput] = PlaceStructure(struct, info, gdsStruct)
%PlaceStructure places polygons from a structure array
%Author: Nicolas Ayotte                                       Creation date: 14/02/2014
%
%     This function receives an input GDS structure to create and place at positions
%     and orientations determined by the info variable. It then updates info to the
%     output positions.
%
%     [struct, info, infoInput]= PlaceStructure(struct, bragg, info)
%     [struct, info]= PlaceStructure(struct, bragg, info)
%
%     VARIABLE NAME   SIZE        DESCRIPTION
%     struct          m|1         internal GDS format structure(s)
%     info.pos        m, 2        current position
%     info.ori        m|1         orientation angle in degrees
%     infoInput.pos   m, 2        input position
%     infoInput.ori   m|1         inverse of input orientation
%
%     See also PlaceRect, PlaceArc, PlaceTaper, PlaceSBend

rows = size(info.pos, 1);

%% Argument validation
if(~isGDSStructure(gdsStruct))
   error('The GDS structure does not have the required fields: xy, layer, dtype, pos, ori, and len.');
end

gdsStruct = NumberOfRows(rows, gdsStruct);

infoInput = InvertInfo(info);

for row = 1 : rows
   cols = size(gdsStruct(row).xy, 2);
   for col = 1 : cols
      if(~isempty(gdsStruct(row).xy{col}))
         xy = RotTransXY(gdsStruct(row).xy{col}, info.pos(row,:), info.ori(row));
         tbraggEl = gds_element('boundary', 'xy', xy, 'layer', gdsStruct(row).layer(col), 'dtype', gdsStruct(row).dtype(col));
         struct = add_element(struct, tbraggEl);
      end
   end
   
   tpos = info.pos(row,:);
   tori = info.ori(row);
   info.pos(row,:) = RotTransXY(gdsStruct(row).pos(1, :), tpos, tori);
   info.ori(row) = tori + gdsStruct(row).ori(1);
   if(isempty(info.length(row, :))); info.length(row, :) = zeros(1, length(info.neff)); end
   tlen = info.length(row, :);
   info.length(row, :) = tlen + repmat(gdsStruct(row).len(1), 1, length(info.neff)) .* info.neff;
   
   % Multiple outputs
   nOutputs = size(gdsStruct(row).pos, 1);
   if(nOutputs > 1)
      for output = 2 : nOutputs
         info.pos(end + 1,:) = RotTransXY(gdsStruct(row).pos(output, :), tpos, tori);
         info.ori(end + 1) =  tori + gdsStruct(row).ori(output);
         info.length(end + 1, :) = tlen;
         info.length(end, :) = tlen + repmat(gdsStruct(row).len(output), 1, length(info.neff)) .* info.neff;
      end
   end
   
end

return