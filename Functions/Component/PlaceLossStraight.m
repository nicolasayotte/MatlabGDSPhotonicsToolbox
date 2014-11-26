function [struct,odimxy] = wglosscar(struct, infoin, WG, FA, couplerref, WGlength, Nitt,varargin)

% Creates Waveguide arrays for loss caracterization
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
%     FA              1, 1        Fiber array structure
%     couplerref      1, 1        Coupler external gds reference
%     WGlength        m|1, n      n waveguides length is goint to be created  at the m position
%     Nitt            m|1, 1      each waveguide is reproduced Nitt times


    %% Varargin and variable check
    
    wgloss.txt = -1; % No information is displayed in TXT in the CAD
    wgloss.orientation = 'horizontal'; % Various waveguide width are oriented "horizontal" or "vertical"
    wgloss = ReadOptions(wgloss, varargin{:});

%% loop

    for ii = 1:length(WG)
        [struct,dimxy] = wglosscarloop(struct, infoin, WG(ii), FA, couplerref, WGlength, Nitt,wgloss.txt);
        if wgloss.orientation(1:3) == 'ver'
            odimxy.len = dimxy(1);
            dimxy(1) = 0;
            infoin.pos = RotTransXY(dimxy, infoin.pos, infoin.ori);
            odimxy.w = infoin.pos(2)-FA.dy;
        else
            odimxy.w = dimxy(2);
            dimxy(2) = 0;
            infoin.pos = RotTransXY(dimxy, infoin.pos, infoin.ori);                
            odimxy.len = infoin.pos(1)-FA.len;
        end
    end
    
end

function [struct,dimxy] = wglosscarloop(struct, infoin, WG, FA, couplerref, WGlength, Nitt,TXTlayer)

    %% Cell parameter calculation

    % dimension calculation

    % par.xo : x-distance to propagate at the entrance of the FA
    % par.xi : x-distance to propagate inside the device
    % par.y0 : y-distance to propagate between the WG
    % par.dy : y-distance to propagate in the last section to match FA.sp
    % par.nturn: number of zig-zag
    % par.nmax: maximum number of zig-zag

    par.nmax = min([FA.sp/WG.sp,FA.sp/(2*WG.r)]);
    if WG.sp > 2*WG.r
        par.y0 = WG.sp-2*WG.r;
    else
        par.y0 = 0;
    end

    if mod(par.nmax,2) ~= 1
        par.nmax = floor(par.nmax)-(1-floor(mod(par.nmax,2)));
        par.dy = FA.sp - par.nmax*(par.y0+2*WG.r);
    else
        par.dy = 0;

    end

    par.xo = 1/(par.nmax+1)*(WGlength-FA.len*(par.nmax-1)-par.nmax*par.y0-par.dy-par.nmax*pi*WG.r);
    par.xi = par.xo+FA.len;

    shortxo = par.xo<FA.safety;
    for ii = 1:length(shortxo)   
        if shortxo(ii) == 1
            dx = FA.safety-par.xo(ii);
            par.xo(ii) = FA.safety;
            par.xi(ii) = par.xi(ii) - dx*2/(par.nmax-1);
        end
    end

    if min([par.xo,par.xi]) < 0 
        error('Input length is too short');
    end

    % Waveguide initial position calculation

    par.distx = par.xo+WG.r+FA.len+max([WG.sp,FA.dx])+WG.r;
    par.distx = [0,cumsum(par.distx(1:end))];
    dimxy = par.distx(end);
    par.distx = par.distx(1:end-1);
    
    par.disty = FA.sp+max([WG.sp, FA.w+FA.dy])*ones(1,Nitt);
    par.disty = [0,cumsum(par.disty(1:end))];
    dimxy(2) = par.disty(end);
    par.disty = par.disty(1:end-1);
    
    for jj = 1:length(WGlength)
        xy = RotTransXY([par.distx(jj)*ones(length(par.disty),1),par.disty'], infoin.pos, infoin.ori);    
        for ii = 1:1:Nitt        
            info{jj} = CursorInfo(xy, infoin.ori, 1);
        end
    end

    oinfo{1} = InvertInfo(info{1});

    %% Create the cell

    for jj = 1:1:length(info)

        [struct,info{jj}] = PlaceCoupler(struct, InvertInfo(info{jj}), couplerref);
        infoin = info{jj};
        [struct, info{jj}] = PlaceRect(struct, info{jj}, par.xo(jj), WG.w, WG.layer, WG.dtype);    
        [struct, info{jj}] = PlaceArc(struct, info{jj}, 90, WG.r, WG.w, WG.layer, WG.dtype,'cladding',false);
        [struct, info{jj}] = PlaceRect(struct, info{jj}, par.dy/2, WG.w, WG.layer, WG.dtype);    
        for ii = 1:floor(par.nmax/2)
            [struct, info{jj}] = PlaceRect(struct, info{jj}, par.y0, WG.w, WG.layer, WG.dtype);    
            [struct, info{jj}] = PlaceArc(struct, info{jj}, 90, WG.r, WG.w, WG.layer, WG.dtype,'cladding',false);
            [struct, info{jj}] = PlaceRect(struct, info{jj}, par.xi(jj), WG.w, WG.layer, WG.dtype);    
            [struct, info{jj}] = PlaceArc(struct, info{jj}, -90, WG.r, WG.w, WG.layer, WG.dtype,'cladding',false);
            [struct, info{jj}] = PlaceRect(struct, info{jj}, par.y0, WG.w, WG.layer, WG.dtype);    
            [struct, info{jj}] = PlaceArc(struct, info{jj}, -90, WG.r, WG.w, WG.layer, WG.dtype,'cladding',false);
            [struct, info{jj}] = PlaceRect(struct, info{jj}, par.xi(jj), WG.w, WG.layer, WG.dtype);    
            [struct, info{jj}] = PlaceArc(struct, info{jj}, 90, WG.r, WG.w, WG.layer, WG.dtype,'cladding',false);
        end
        [struct, info{jj}] = PlaceRect(struct, info{jj}, par.y0+par.dy/2, WG.w, WG.layer, WG.dtype);    
        [struct, info{jj}] = PlaceArc(struct, info{jj}, 90, WG.r, WG.w, WG.layer, WG.dtype,'cladding',false);
        [struct, info{jj}] = PlaceRect(struct, info{jj}, par.xo(jj), WG.w, WG.layer, WG.dtype);    
        [struct] = PlaceCoupler(struct, info{jj}, couplerref);

        % Place TXT info
        if TXTlayer ~= -1
            for ii = 1:1:length(info{jj}.ori)
%                 txt2write = ['Path length = ',num2str(round(info{jj}.length(ii))),' um, WG width = ',num2str(WG.w(1)*1e3),' nm'];
%                 strEl = gds_element('text', 'text', txt2write, 'xy', info{jj}.pos(ii,:), 'layer', TXTlayer);
%                 struct = add_element(struct, strEl);                
                
                txt2write = ['opt_in_#',num2str(ii),', FA = ',num2str(FA.sp),' um, Path length = ',num2str(round(info{jj}.length(ii))),' um, WG width = ',num2str(WG.w(1)*1e3),' nm'];
                strEl = gds_element('text', 'text', txt2write, 'xy', infoin.pos(ii,:), 'layer', TXTlayer);
                struct = add_element(struct, strEl);
            end
        end
    end     

end