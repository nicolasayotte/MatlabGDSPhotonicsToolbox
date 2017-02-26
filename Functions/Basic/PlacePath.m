function [structure, info, infoInput] = PlacePath(structure, info, Z, WaveGuide, varargin)

% Z = PathSpiral(2,50e-6,0.6,10e-6); PlacePath(Z, [0.5e-6,5e-6])

%PLACEARC places polygons in custom path shape in a gds structure
%Author : Alexandre D. Simard                     Creation date : 20/05/2016 
%
%     This function receives an input GDS structure and one or many path
%     to create and place at positions and orientations determined by the info
%     variable. It then updates info to the output positions of the path

%% Default values for valid options
options.maxVertices = 199;
options.flip = false;
options = ReadOptions(options, varargin{ : });

%% Arguments validation

% double check the length of info and the amount of path
rows = size(info.pos, 1);
cols = length(WaveGuide.w);

[Z, WaveGuide] = NumberOfRows(rows, Z, WaveGuide);

%% Place the Path in polygons
infoInput = InvertInfo(info);

count = 0;
for row = 1:rows    
    
    Zloc = Z{row};
    NZloc = -Derivate(imag(Zloc))./sqrt(Derivate(imag(Zloc)).^2+Derivate(real(Zloc)).^2)+i*Derivate(real(Zloc))./sqrt(Derivate(imag(Zloc)).^2+Derivate(real(Zloc)).^2);% vecteur unitaire normal a Z
    TZloc = Derivate(real(Zloc))./sqrt(Derivate(imag(Zloc)).^2+Derivate(real(Zloc)).^2)+i*Derivate(imag(Zloc))./sqrt(Derivate(imag(Zloc)).^2+Derivate(real(Zloc)).^2);% vecteur unitaire tangeant a Z    
    position = cumsum(sqrt(Derivate(real(Zloc)).^2+Derivate(imag(Zloc)).^2));position = position - position(1);
    L(row) = position(end);
    
    Npolygon = ceil(length(Zloc)/(options.maxVertices/2)) + 1;
    Nstep = floor(length(Zloc)/(Npolygon - 1));
    for col = 1:cols          
        for ii = 1:Npolygon + 1  
            indice = Nstep*(ii-1):Nstep*(ii);
            indice = indice(indice~=0);
            indice = indice(indice<=length(Zloc));
            if ~isempty(indice)
                xy = [Zloc(indice) + NZloc(indice)*WaveGuide(row).w(col)/2;Zloc(indice(end:-1:1)) - NZloc(indice(end:-1:1))*WaveGuide(row).w(col)/2;Zloc(indice(1)) + NZloc(indice(1))*WaveGuide(row).w(col)/2];                 
                xy = [real(xy),imag(xy)];            
                count = count+1;
                rectEl{count} = gds_element('boundary', 'xy', RotTransXY(xy, info.pos(row, : ), info.ori(row)), 'layer', WaveGuide(row).layer(1, col), 'dtype',  WaveGuide(row).dtype(1, col));
            end
        end                
    end 
    info.pos(row, : ) = RotTransXY([real(Zloc(end)-Zloc(1)),imag(Zloc(end)-Zloc(1))],info.pos(row, : ),info.ori(row));
    info.ori(row) = ConstrainAngle(info.ori(row) + angle(TZloc(end))/2/pi*360);
end
structure = add_element(structure, rectEl(cellfun(@(x)~isempty(x), rectEl)));
info.length = info.length  + L'*info.neff;

return
