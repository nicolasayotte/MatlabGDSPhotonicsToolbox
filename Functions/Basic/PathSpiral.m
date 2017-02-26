function [Zout] = PathSpiral(Nturn,R0,alpha,WGspacing,varargin)

% This function create a spiral path in the complex plane that can be used with PlacePath to
% create gds polygons. The input is located pos (0,0) with ori = 0

% PathSpiral(2,50e-6,0.6,10e-6,'display',true);

%% Arguments validation
rows = max([size(Nturn, 1),size(R0, 1),size(alpha, 1),size(WGspacing, 1)]);
cols = max([size(Nturn, 2),size(R0, 2),size(alpha, 2),size(WGspacing, 2)]);

if rows > 1
  error('Only one row can be provided');
end

[Nturn, R0, alpha, WGspacing] = NumberOfColumns(cols,  Nturn, R0, alpha, WGspacing);

%% Default value for valid options
options.Npoints = 2000; % Number of point used to create the path
options.flip = false; % if true, the spiral is in the negative portion of the complex plane
options.proxy = false; % If true, the waveguides are terminated parallel to each other
options.switch = false; % If true, the waveguides input/output are interchanged (used only with proxy)
options.display = false; % If true, a matlab figure is created to visualize the spiral
options.figure = false; % If true, a matlab figure is created to visualize the spiral
options = ReadOptions(options, varargin{ : });

%Post-processing of options
options.Npoints = options.Npoints*Nturn;

%% Spiral creation

for col = 1:cols
  
  if options.proxy
    if options.switch
      radius = linspace(-(Nturn(col)+0.5)*pi,(Nturn(col)-0.5)*pi,options.Npoints(col))';
    else
      radius = linspace(-(Nturn(col)-0.5)*pi,(Nturn(col)+0.5)*pi,options.Npoints(col))';
    end
  else
    radius = linspace(-Nturn(col)*pi,Nturn(col)*pi,options.Npoints(col))';
  end
  
  R = R0(col)*sign(radius) + WGspacing(col)*radius/pi;
  dx = R0(col)*sign(radius).*exp(-abs(radius)/alpha(col));
  
  
  Z = R.*exp(1i*abs(radius)) - dx;
  NZ = -Derivate(imag(Z))./sqrt(Derivate(imag(Z)).^2+Derivate(real(Z)).^2)+1i*Derivate(real(Z))./sqrt(Derivate(imag(Z)).^2+Derivate(real(Z)).^2);% vecteur unitaire normal a Z
  TZ = Derivate(real(Z))./sqrt(Derivate(imag(Z)).^2+Derivate(real(Z)).^2)+1i*Derivate(imag(Z))./sqrt(Derivate(imag(Z)).^2+Derivate(real(Z)).^2);% vecteur unitaire tangeant a Z
  
  % Brings Z(1) at pos (0,0) with ori = 0
  Z = Z*exp(-1i*angle(TZ(1)));
  NZ = -Derivate(imag(Z))./sqrt(Derivate(imag(Z)).^2+Derivate(real(Z)).^2)+1i*Derivate(real(Z))./sqrt(Derivate(imag(Z)).^2+Derivate(real(Z)).^2);% vecteur unitaire normal a Z
  TZ = Derivate(real(Z))./sqrt(Derivate(imag(Z)).^2+Derivate(real(Z)).^2)+1i*Derivate(imag(Z))./sqrt(Derivate(imag(Z)).^2+Derivate(real(Z)).^2);% vecteur unitaire tangeant a Z
  Z = Z - Z(1);
  
  if ~options.flip
    Z = real(Z) - 1i*imag(Z);
  end
  
  
  if options.proxy
    if real(Z(end)) < 0
      Z(end+1) = real(Z(end)) - abs(real(Z(end)) - real(Z(end-1)))  + 1i*imag(Z(end));
      Z = [real(Z(end)); Z];
      Z = Z - Z(1);
    else
      Z(end+1) = 1i*imag(Z(end));
    end
  end
  
  X = real(Z);
  Y = imag(Z);
  Rloc = ((diff(X).^2+diff(Y).^2).^(3/2))./(diff(X).*Derivate(diff(Y))-diff(Y).*Derivate(diff(X))); % Local radius of curvature
  position = cumsum(sqrt(Derivate(real(Z)).^2+Derivate(imag(Z)).^2));position = position - position(1);
  position = position(1:end-1);
  
  ww = max(real(Z)) - min(real(Z));
  wh = max(imag(Z)) - min(imag(Z));
  
  if (options.figure)
    figure();
    subplot(2,1,1),hold all,box on;
    plot(Z);
    xlabel('Position (\mum)','fontsize',15);
    ylabel('Position (\mum)','fontsize',15);
    axis tight;aaa = axis;set(gca,'PlotBoxAspectRatio',[aaa(2)-aaa(1) aaa(4)-aaa(3) 1]);clear aaa;
    subplot(2,1,2),hold all,box on;
    plot(position,abs(Rloc));
    xlabel('Position (\mum)','fontsize',15);
    ylabel('Radius (\mum)','fontsize',15);
    axis tight;aaa = axis;
    aaa(4) = max([Rloc(1),Rloc(end)]);axis(aaa);
  end
  if (options.display)
    disp(' ');
    disp(['Spiral ',num2str(col)]);
    disp(['L = ',num2str(1e-3*position(end),3),' mm']);
    disp(['w x h = ',num2str(ww*1e-3,3),'x',num2str(wh*1e-3,3),' mm^2']);
    disp(['Rmin = ',num2str(min(abs(Rloc)),3),' um']);
    disp(' ');
  end
  
  Zout{col,1} = Z;
end

return