function [struct,infoout,Nbentout] = curvedwgloss(struct, infoin, WG, Nbent)

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
        

    %% Cell parameter calculation

Ntot = ceil(((Nbent-2)/8));
Nbentout = ceil(((Nbent-2)/8))*8+2;

    %% Create the cell

            
    [struct, infoout] = PlaceArc(struct, infoin, -90, WG.r, WG.w, WG.layer, WG.dtype,'cladding',false);
    
    for ii = 1:Ntot
        [struct, infoout] = PlaceRect(struct, infoout, WG.sp, WG.w, WG.layer, WG.dtype);
        [struct, infoout] = PlaceArc(struct, infoout, 90, WG.r, WG.w, WG.layer, WG.dtype,'cladding',false);
        [struct, infoout] = PlaceRect(struct, infoout, WG.sp, WG.w, WG.layer, WG.dtype);
        [struct, infoout] = PlaceArc(struct, infoout, 90, WG.r, WG.w, WG.layer, WG.dtype,'cladding',false);
        [struct, infoout] = PlaceRect(struct, infoout, WG.sp, WG.w, WG.layer, WG.dtype);
        [struct, infoout] = PlaceArc(struct, infoout, -90, WG.r, WG.w, WG.layer, WG.dtype,'cladding',false);
        [struct, infoout] = PlaceRect(struct, infoout, WG.sp, WG.w, WG.layer, WG.dtype);
        [struct, infoout] = PlaceArc(struct, infoout, -90, WG.r, WG.w, WG.layer, WG.dtype,'cladding',false);
    end

        [struct, infoout] = PlaceRect(struct, infoout, WG.sp*3+2*WG.r, WG.w, WG.layer, WG.dtype);
        [struct, infoout] = PlaceArc(struct, infoout, -90, WG.r, WG.w, WG.layer, WG.dtype,'cladding',false);

    for ii = 1:Ntot
        [struct, infoout] = PlaceRect(struct, infoout, WG.sp, WG.w, WG.layer, WG.dtype);
        [struct, infoout] = PlaceArc(struct, infoout, -90, WG.r, WG.w, WG.layer, WG.dtype,'cladding',false);
        [struct, infoout] = PlaceRect(struct, infoout, WG.sp, WG.w, WG.layer, WG.dtype);
        [struct, infoout] = PlaceArc(struct, infoout, 90, WG.r, WG.w, WG.layer, WG.dtype,'cladding',false);
        [struct, infoout] = PlaceRect(struct, infoout, WG.sp, WG.w, WG.layer, WG.dtype);
        [struct, infoout] = PlaceArc(struct, infoout, 90, WG.r, WG.w, WG.layer, WG.dtype,'cladding',false);
        [struct, infoout] = PlaceRect(struct, infoout, WG.sp, WG.w, WG.layer, WG.dtype);
        [struct, infoout] = PlaceArc(struct, infoout, -90, WG.r, WG.w, WG.layer, WG.dtype,'cladding',false);
    end
            
end