function [structgds, infoOut, infoIn, infoInBias, infoOutBias, WGw, WGBias]= PlaceCPS(structgds, info, len, CPSinfo, varargin)
%PlaceCPS places a coplanar strip (CPS) in a gds structure
%Author : Alexandre D. Simard                     Creation date: 11/11/2014
%
%     This function receives an input GDS structure and the parameters for one or many
%     rectangles to create and place at positions and orientations determined by the info
%     variable. It then updates info to the output positions.
%
%     See also CPS, PlaceRect


%% Arguments validation
rows = size(info.pos, 1);
[CPSinfo] = NumberOfRows(rows, CPSinfo);
outputBias = false;

%% Place CPS
NroutingWG = 1;
Nbias = 1;
for row = 1:rows
  infoloc = SplitInfo(info,row);
  
  for ii = 1:length(CPSinfo(row).layer)
    
    infoii = infoloc;
    
    infoii.ori = infoii.ori + 90*sign(CPSinfo(row).shift(ii));
    [~, infoii] = PlaceRect(structgds, infoii, abs(CPSinfo(row).shift(ii)), 1, 1, 1);
    infoii.ori = infoii.ori - 90*sign(CPSinfo(row).shift(ii));
    
    [structgds, infoiiout] = PlaceRect(structgds,infoii, len, CPSinfo(row).w(ii), CPSinfo(row).layer(ii), CPSinfo(row).dtype(ii));
    
    % find info for routing
    if any(CPSinfo(row).layer(ii) == CPSinfo(row).routinglayer) &&  any(CPSinfo(row).dtype(ii) == CPSinfo(row).routingdtype)
      infoOut{NroutingWG} = infoiiout;
      infoIn{NroutingWG} = infoii;
      WGw(NroutingWG,1) = CPSinfo(row).w(ii);
      NroutingWG = NroutingWG + 1;
    end
    % find info for bias
    if any(CPSinfo(row).layer(ii) == CPSinfo(row).SPPgroundlayer) &&  any(CPSinfo(row).dtype(ii) == CPSinfo(row).SPPgrounddtype)
      infoOutBias{Nbias} = infoiiout;
      infoInBias{Nbias} = infoii;
      WGBias(Nbias,1)=CPSinfo(row).w(ii);
      Nbias = Nbias + 1;
      outputBias = true;
    end
    
  end
  
  % Place Inductive Bridge
  
  if isfield(CPSinfo(row),'IndBridg')
    for ii = 1:size(CPSinfo(row).IndBridg.layer,2)
      braggIndBridg = BraggFromParameters(len, 0, CPSinfo(row).IndBridg.period, CPSinfo(row).IndBridg.w(ii)/2, ...
        CPSinfo(row).IndBridg.len(ii)/CPSinfo(row).IndBridg.period,...
        0, [], CPSinfo(row).IndBridg.layer(ii), CPSinfo(row).IndBridg.dtype(ii));
      infoshift = SplitInfo(CloneInfo(infoloc, 2, CPSinfo(row).IndBridg.shiftx(ii), CPSinfo(row).IndBridg.shifty(ii), 0),2);
      [structgds] = PlaceStructure(structgds, infoshift, braggIndBridg);
    end
    
  end
  
end

infoOut = MergeInfo(infoOut{:});
infoIn = InvertInfo(MergeInfo(infoIn{:}));
if outputBias
  infoInBias = InvertInfo(MergeInfo(infoInBias{:}));
  infoOutBias = MergeInfo(infoOutBias{:});
else
  WGBias = [];
  infoInBias = [];
  infoOutBias = [];
end
