function difz = deriv(z)
    dz = diff(z);    

    vectsize = size(z);vectsize(vectsize == max(vectsize)) = max(vectsize)+1;
    z_demi_entier = zeros(vectsize);
    z_demi_entier(2:end-1) = z(1:end-1)+dz/2;
    z_demi_entier(1) =z_demi_entier(2)-dz(1);
    z_demi_entier(end) = z_demi_entier(end-1)+dz(end);
    
    difz = diff(z_demi_entier);
return
