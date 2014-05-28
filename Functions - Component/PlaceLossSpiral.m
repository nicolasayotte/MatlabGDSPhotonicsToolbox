function [struct,infoout,Nbentout] = spiralrect(struct, infoin, WG, Nbent)

% Creates spiral WG
% Author: Alexandre D. Simard                                Creation date: 27/03/2014

%     This function receives an input GDS structure and the parameters for one or many
%     waveguide array to create and place at positions and orientations determined by the info
%     variable.
%
%     [struct] = wglosscar(struct, info, WG, FA, couplerref, WGlength, Nitt, layer, datatype)
%     [struct] = wglosscar(struct, info, WG, FA, couplerref, WGlength,Nitt, layer, datatype)
%
%     VARIABLE NAME   SIZE        DESCRIPTION
% 	  infoin            m|1, 1      info structure localising the m arrays
%     WG              m|1, 1      waveguide structure (with m differnet type of WG)
%     Nbent            m|1, 1      Number of 90 degrees bent

    %% Varargin and variable check
        
    if WG.r ~= WG.sp
        aaa = min([WG.r,WG.sp])
        WG.r = aaa;
        WG.sp = aaa;
        warning(['Warning, WG.r = WG.sp = ',num2str(aaa)])
    end

    %% Cell parameter calculation

% par.Ntot : Number of turn around the central section    

par.Ntot = ceil((Nbent/8))-1;
Nbentout = ceil((Nbent/8))*8;
    %% Create the cell
for jj = 1:1:length(infoin.length)
    infoloc = SplitInfo(infoin, jj);
    infoloc2 = infoloc;infoloc2.length=0;
    
        [~, infoloc2] = PlaceArc(struct, infoloc2, 90, 0, WG.w, WG.layer, WG.dtype,'metal',true);
        [~, infoloc2] = PlaceRect(struct, infoloc2, WG.sp, WG.w, WG.layer, WG.dtype);    
        [~, infoloc2] = PlaceArc(struct, infoloc2, -90, 0, WG.w, WG.layer, WG.dtype,'metal',true);
    
    % output position calculation
    infooutloc = InvertInfo(infoloc2);
    if jj == 1
        infoout = infooutloc;
    else
        infoout = MergeInfo(infoout,infooutloc);    
    end
    
    infoloc = MergeInfo(infoloc,infoloc2);clear infoloc2;
    Nloc = par.Ntot;
    for ii = 1:par.Ntot
    
        [struct, infoloc] = PlaceRect(struct, infoloc, WG.sp*(5+4*Nloc) , WG.w, WG.layer, WG.dtype);    
        [struct, infoloc] = PlaceArc(struct, infoloc, 90, WG.r, WG.w, WG.layer, WG.dtype,'group',true,'cladding',false);
        [struct, infoloc] = PlaceRect(struct, infoloc, WG.sp*(2+4*Nloc) , WG.w, WG.layer, WG.dtype);    
        [struct, infoloc] = PlaceArc(struct, infoloc, 90, WG.r, WG.w, WG.layer, WG.dtype,'group',true,'cladding',false);
        [struct, infoloc] = PlaceRect(struct, infoloc, WG.sp*(3+4*Nloc) , WG.w, WG.layer, WG.dtype);    
        [struct, infoloc] = PlaceArc(struct, infoloc, 90, WG.r, WG.w, WG.layer, WG.dtype,'group',true,'cladding',false);
        [struct, infoloc] = PlaceRect(struct, infoloc, WG.sp*(4*Nloc) , WG.w, WG.layer, WG.dtype);    
        [struct, infoloc] = PlaceArc(struct, infoloc, 90, WG.r, WG.w, WG.layer, WG.dtype,'group',true,'cladding',false);
        Nloc = Nloc-1;
        
    end
        [struct, infoloc] = PlaceRect(struct, infoloc, WG.sp*(5), WG.w, WG.layer, WG.dtype);    
        [struct, infoloc] = PlaceArc(struct, infoloc, 90, WG.r, WG.w, WG.layer, WG.dtype,'group',true,'cladding',false);
        [struct, infoloc] = PlaceRect(struct, infoloc, WG.sp*(2), WG.w, WG.layer, WG.dtype);    
        [struct, infoloc] = PlaceArc(struct, infoloc, 90, WG.r, WG.w, WG.layer, WG.dtype,'group',true,'cladding',false);
        [struct, infoloc] = PlaceRect(struct, infoloc, WG.sp*(1), WG.w, WG.layer, WG.dtype);    
        [struct, infoloc] = PlaceArc(struct, infoloc, 90, WG.r, WG.w, WG.layer, WG.dtype,'group',true,'distance',2*WG.sp+WG.r,'cladding',false);
        [struct, infoloc] = PlaceRect(struct, infoloc, WG.sp*(1), WG.w, WG.layer, WG.dtype);  
        infoloc1 = SplitInfo(infoloc, 1);infoloc1.length = infoloc.length(1);
        infoloc2 = SplitInfo(infoloc, 2);infoloc2.length = infoloc.length(2);
        [struct, infoloc1] = PlaceArc(struct, infoloc1, 90, WG.r, WG.w, WG.layer, WG.dtype,'group',true,'cladding',false);
        [struct, infoloc2] = PlaceArc(struct, infoloc2, -90, WG.r, WG.w, WG.layer, WG.dtype,'group',true,'cladding',false);
        [struct, infoloc2] = PlaceRect(struct, infoloc2, WG.sp*(1), WG.w, WG.layer, WG.dtype);    
        
        % output length calculation
        infoout.length(jj) = infoloc1.length+infoloc2.length;        
        
end

end