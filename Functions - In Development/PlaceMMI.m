function [structgds, InfoOut, infoIn]= PlaceMMI(structgds, info, RWin, RWout, MMIinfo, varargin)

% function [structgds, pos, ori, inpos,inori]= PlaceMMI(structgds,RWin,RWout,MMIinfo,pos,ori,varargin)

% MMIinfo.layer => for taper
% MMIinfo.dtype => for dtype
% MMIinfo.ff =>  fill factor from 0 to 1
% MMIinfo.w
% MMIinfo.len
% MMIinfo.tapl

% mmivar.nout : 
% mmivar.sbentout: if true (default), the ouput wg are possitionned to match RWout.sp using an sbent
% mmivar.taperout: if true (default), the ouput wg width are adjusted to match RWout.w using a taper
% mmivar.taperin: if false (ture is the default), the input waveguide width is overrided to matfch the input waveguide width

%% Parameter validation

mmivar.nout = []; % default value: if mmivar.nout > 0 & length(infoIn.ori) == 1, 
                  % there is one input waveguides centered in the MMIinfo, 
                  % mmivar.nout output waveguides
                  % and the MMIinfo.len is divided by 4
mmivar.sbentout = true;
mmivar.taperout = true;
mmivar.taperin = true;
mmivar.sbentlength = 20;
mmivar.backgroundRect = false; % for place SBENT
mmivar.type = 'cladding'; % for type place SBENT
mmivar = ReadOptions(mmivar, varargin{:});

if mmivar.sbentout == true & mmivar.taperout ~= true
   error('A taper is required to use the sbent');
end

if mmivar.nout ~= abs(round(mmivar.nout))
    error('nout must be a positive integer');
end

if isempty(mmivar.nout) == 0 %(isnot empty)    
    if length(info.ori)~=1 && length(info.pos(:,1)) ~= 1
        error('When specifying nout, only one input waveguide is allowed');
    end  
    MMIinfo.nout = mmivar.nout;
    MMIinfo.len = MMIinfo.len/4;
else
    MMIinfo.nout = length(info.ori);
end

infoIn = InvertInfo(info);

%% Distance between input waveguides of the MMI and sbent length

sectw = min(MMIinfo.w)/(MMIinfo.nout); % subsection of MMI width
relinMMI = sectw;

%% Input waveguides sbent

    if mmivar.sbentlength~=0
        
        [structgds, info] = PlaceRect(structgds, info, 5, RWin.w, RWin.layer, RWin.dtype);

        [structgds, info,infodrcclean] = PlaceSBend(structgds, info, mmivar.sbentlength, 0, RWin.r, RWin.w, RWin.layer, RWin.dtype, 'group', true, 'distance', relinMMI,'backgroundRect',mmivar.backgroundRect,'type',mmivar.type);

        infodrccleanpos = mean(infodrcclean.pos);
        infodrcclean = InvertInfo(SplitInfo(infodrcclean,1));infodrcclean.pos = infodrccleanpos;
%         if min(mean(info.pos))*2>0
%             [structgds] = PlaceRect(structgds, infodrcclean, 5+max(abs(infodrcclean.pos-mean(info.pos))), min(mean(info.pos))*2, RWin.layer(2), RWin.dtype(2));
%         end
        [structgds, info] = PlaceRect(structgds, info, 5, RWin.w, RWin.layer, RWin.dtype);

    end


%% Input waveguides taper

if mmivar.taperin == true
    
    if length(info.ori) == 1
        
        taper = Taper(RWin.w, [sectw*MMIinfo.ff,MMIinfo.w(2)], MMIinfo.layer, MMIinfo.dtype);
        
    else
        
        taper = Taper([RWin.w(1),MMIinfo.w(2)-sectw], [sectw*MMIinfo.ff,MMIinfo.w(2)-sectw], MMIinfo.layer, MMIinfo.dtype);
        
    end
    
    [structgds, info] = PlaceTaper(structgds, info, taper, MMIinfo.tapl);
    
end
%% MMI rectangle

if length(info.ori) == 1
    
    [structgds, info] = PlaceRect(structgds, info, MMIinfo.len, MMIinfo.w, MMIinfo.layer, MMIinfo.dtype);

    % create the info structure at the output of the MMI
    
        [~, info1] = PlaceArc(structgds, info, -90, 0, 0, 0, 0,'type','metal');
        [~, info2] = PlaceArc(structgds, info, 90, 0, 0, 0, 0,'type','metal');
    
        if MMIinfo.nout/2 == round(MMIinfo.nout/2)    % nout even
            devlen =  sectw/2;
            for ii = 1:1:(MMIinfo.nout/2)-1
                info1 = MergeInfo(info1,info1);
                info2 = MergeInfo(info2,info2);
                devlen = [devlen,devlen(end)+sectw];
            end    
            [~, info1] = PlaceRect(structgds, info1, devlen', 0*devlen', MMIinfo.layer(1), MMIinfo.dtype(1));
            [~, info2] = PlaceRect(structgds, info2, devlen', 0*devlen', MMIinfo.layer(1), MMIinfo.dtype(1));
            [~, info1] = PlaceArc(structgds, info1, 90, 0, 0, MMIinfo.layer, MMIinfo.dtype,'type','metal');
            [~, info2] = PlaceArc(structgds, info2, -90, 0, 0, MMIinfo.layer, MMIinfo.dtype,'type','metal');
            info = CheckParallelAndNormal(MergeInfo(info1,info2));
        else                                            % nout odd
            devlen =  sectw;
            for ii = 1:1:(MMIinfo.nout-1)/2-1
                info1 = MergeInfo(info1,info1);
                info2 = MergeInfo(info2,info2);
                devlen = [devlen,devlen(end)+sectw];
            end        
            [~, info1] = PlaceRect(structgds, info1, devlen', 0*devlen', MMIinfo.layer(1), MMIinfo.dtype(1));
            [~, info2] = PlaceRect(structgds, info2, devlen', 0*devlen', MMIinfo.layer(1), MMIinfo.dtype(1));
            [~, info1] = PlaceArc(structgds, info1, 90, 0, 0, MMIinfo.layer, MMIinfo.dtype,'type','metal');
            [~, info2] = PlaceArc(structgds, info2, -90, 0, 0, MMIinfo.layer, MMIinfo.dtype,'type','metal');
            info = CheckParallelAndNormal(MergeInfo(info,info1,info2));
        end

else
    MMIw = MMIinfo.w/2;
    MMIw(2) = MMIinfo.w(2)-sectw;
    
    [structgds, info] = PlaceRect(structgds, info, MMIinfo.len, MMIw, MMIinfo.layer, MMIinfo.dtype);

end


%% Out waveguides taper

if mmivar.taperout == true
    
    taper = Taper([sectw*MMIinfo.ff,MMIinfo.w(2)-sectw],[RWout.w(1),MMIinfo.w(2)-sectw], MMIinfo.layer, MMIinfo.dtype);
    
    [structgds, info] = PlaceTaper(structgds, info, taper, MMIinfo.tapl);

    if mmivar.sbentout == true
        
       % Output waveguides sbent

    if mmivar.sbentlength~=0
        
        [structgds, info] = PlaceRect(structgds, info, 5, RWout.w, RWout.layer, RWout.dtype);
                
        [structgds, info,infoinput] = PlaceSBend(structgds, info, mmivar.sbentlength, 0, RWout.r, RWout.w, RWout.layer, RWout.dtype, 'group', true, 'distance', RWout.sp,'backgroundRect',mmivar.backgroundRect,'type',mmivar.type);

%         infodrcclean = InvertInfo(SplitInfo(info,2));infodrcclean.pos = mean(info.pos);
%         [structgds] = PlaceRect(structgds, infodrcclean, 5+max(abs(infodrcclean.pos-mean(infoinput.pos))),min(mean(info.pos))*2, RWout.layer(2), RWout.dtype(2));
        
        [structgds, info] = PlaceRect(structgds, info, 5, RWout.w, RWout.layer, RWout.dtype);
        end
        
    end
    
end

InfoOut = info;