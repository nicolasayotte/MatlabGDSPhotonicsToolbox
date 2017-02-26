function [structgds, infoOut, infoIn,infoR, infoL]= PlaceVias(structgds, info, Viainfo, varargin)
%
% Place vias stack between the first layer and the last layer. The output
% info are the four lattices of the last layer

%% Parameter validation

plVias.align = 'center'; % default value (center), left or right; Align the Vias on the first via layer
plVias.wgwidth = 10; % default value (center), left or right; Align the Vias on the first via layer

plVias = ReadOptions(plVias, varargin{:});

rows = size(info.pos, 1);
[Viainfo, plVias.wgwidth] = NumberOfRows(rows, Viainfo, plVias.wgwidth);

%% Place IBG that can be used in reflection

for row = 1:rows

    % Find Vias y shift from align

    HalfWidthshift = abs(Viainfo(row).w(1)/2 - plVias.wgwidth/2);
    switch plVias.align
        case 'right'                                
            shiftalign =HalfWidthshift;
        case 'left'            
            shiftalign =-HalfWidthshift;
        otherwise
            shiftalign = 0;
    end
              
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    Nvias = length(Viainfo(row).w);
    for ii = 1:Nvias
        infoloop = SplitInfo(info,row);
        
        % shiftx position        
        if Viainfo(row).shiftx(ii)>0
            [~, infoloop] = PlaceRect(structgds, infoloop, Viainfo(row).shiftx(ii), Viainfo(row).w(ii), Viainfo(row).layer(ii), Viainfo(row).dtype(ii));
        elseif Viainfo(row).shiftx(ii)<0
            infoloop = InvertInfo(infoloop);
            [~, infoloop] = PlaceRect(structgds, infoloop, abs(Viainfo(row).shiftx(ii)), Viainfo(row).w(ii), Viainfo(row).layer(ii), Viainfo(row).dtype(ii));
            infoloop = InvertInfo(infoloop);        
        end

        % shifty position        
        if Viainfo(row).shifty(ii)+shiftalign~=0
            infoloop.ori = infoloop.ori + 90*sign(Viainfo(row).shifty(ii)+shiftalign);                       
            [~, infoloop] = PlaceRect(structgds, infoloop, abs(Viainfo(row).shifty(ii)+shiftalign), Viainfo(row).w(ii), Viainfo(row).layer(ii), Viainfo(row).dtype(ii));
            infoloop.ori = infoloop.ori - 90*sign(Viainfo(row).shifty(ii)+shiftalign);                            
        end        

        [structgds,infoloopout] = PlaceRect(structgds,infoloop, Viainfo(row).len(ii), Viainfo(row).w(ii), Viainfo(row).layer(ii), Viainfo(row).dtype(ii));    
    
    end
    
     infoOut{row} = infoloopout;
     infoIn{row} = InvertInfo(infoloop);
        [~,infohalflength] = PlaceRect(structgds,infoloop, Viainfo(row).len(ii)/2, Viainfo(row).w(ii), Viainfo(row).layer(ii), Viainfo(row).dtype(ii));        
     
    infoR{row} = infohalflength;
        infoR{row}.ori = infoR{row}.ori-90;
        [~,infoR{row}] = PlaceRect(structgds,infoR{row}, Viainfo(row).w(ii)/2, Viainfo(row).w(ii), Viainfo(row).layer(ii), Viainfo(row).dtype(ii));        
        
        
    infoL{row} = infohalflength;
        infoL{row}.ori = infoL{row}.ori+90;
        [~,infoL{row}] = PlaceRect(structgds,infoL{row}, Viainfo(row).w(ii)/2, Viainfo(row).w(ii), Viainfo(row).layer(ii), Viainfo(row).dtype(ii));        
end

infoOut = MergeInfo(infoOut{:});
infoIn = MergeInfo(infoIn{:});
infoR = MergeInfo(infoR{:});
infoL = MergeInfo(infoL{:});

