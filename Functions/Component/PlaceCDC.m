function [structure, infoTr, infoRef, infoDrop, infoAdd] = PlaceCDC(structure, info, phW, bragg1, bragg2, side2side, taperlen, varargin)
%PlaceCDC places a co-directional coupler
%Author : Alexandre D. Simard                              Creation date : 01/11/2014
%
%     This function that two bragg gratings and creates a CDC.
%
%
%     OPTION NAME       SIZE        DESCRIPTION
%     'side'            1           [1] || -1 changes the input waveguide
%
%     See also PlaceArc, PlaceTaper, PlaceSBend, PlaceCompactUTurn

rows = size(info.pos, 1);


%% Default values for valid options
options.side = 1;
options = ReadOptions(options, varargin{:});


%% Argument validation
[phW, bragg1, bragg2, side2side, taperlen] = NumberOfRows(rows, phW, bragg1, bragg2, side2side, taperlen);


%% Place IBG that can be used in reflection
for row = 1 : rows
   taper1 = Taper(bragg1(row).w, phW(row).w, phW(row).layer, phW(row).dtype);
   taper2 = Taper(bragg2(row).w, phW(row).w, phW(row).layer, phW(row).dtype);
   
   %     Define info position
   infoRowTr = SplitInfo(info,row);
   infoRowRef = InvertInfo(infoRowTr);
   
   [~, infoRowDrop] = PlaceArc(structure, infoRowTr, 90*options.side, 0, 0, phW(row).layer, phW(row).dtype,'type','metal');
   [~, infoRowDrop] = PlaceRect(structure,infoRowDrop, phW(row).sp, 0, phW(row).layer, phW(row).dtype);
   [~, infoRowDrop] = PlaceArc(structure, infoRowDrop, options.side*90, 0, 0, phW(row).layer, phW(row).dtype,'type','metal');
   infoRowAdd = InvertInfo(infoRowDrop);
   
   % Place tapers, Sbend and structure and sbent, tapers
   shiftpos = phW(row).sp-(bragg1(row).w(1)/2+bragg2(row).w(1)/2+side2side(row));
   
   [structure, infoRowTr] = PlaceTaper(structure, infoRowTr, taper1, taperlen(row),'invert',true);
   [structure, infoRowTr] = PlaceSBend(structure, infoRowTr, 2*shiftpos, options.side*shiftpos/2, phW(row).r, bragg1(row).w, phW(row).layer, phW(row).dtype);
   [structure,infoRowTr] = PlaceStructure(structure, infoRowTr, bragg1(row));
   [structure, infoRowTr] = PlaceSBend(structure, infoRowTr, 2*shiftpos, -options.side*shiftpos/2, phW(row).r, bragg1(row).w, phW(row).layer, phW(row).dtype);
   [structure, infoRowTr] = PlaceTaper(structure, infoRowTr, taper1, taperlen(row));
   
   [structure, infoRowAdd] = PlaceTaper(structure, infoRowAdd, taper2, taperlen(row),'invert',true);
   [structure, infoRowAdd] = PlaceSBend(structure, infoRowAdd, 2*shiftpos, -options.side*shiftpos/2, phW(row).r, bragg2(row).w, phW(row).layer, phW(row).dtype);
   [structure, infoRowAdd] = PlaceStructure(structure, infoRowAdd, bragg2(row));
   [structure, infoRowAdd] = PlaceSBend(structure, infoRowAdd, 2*shiftpos, options.side*shiftpos/2, phW(row).r, bragg2(row).w, phW(row).layer, phW(row).dtype);
   [structure, infoRowAdd] = PlaceTaper(structure, infoRowAdd, taper2, taperlen(row));
   
   infoTr{row} = infoRowTr;
   infoDrop{row} = infoRowDrop;
   infoRef{row} = infoRowRef;
   infoAdd{row} = infoRowAdd;
   
end

infoTr = MergeInfo(infoTr{:});
infoDrop = MergeInfo(infoDrop{:});
infoRef = MergeInfo(infoRef{:});
infoAdd = MergeInfo(infoAdd{:});

end
