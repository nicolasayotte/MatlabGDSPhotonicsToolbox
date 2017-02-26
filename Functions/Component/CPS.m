function outCPS = CPS(CPSWG, Xin, Xout, layerInfo, varargin)
% Create a coplanar strip (CPS) information structure. The output infos of
% PlaceCPS is composed of the layers of the last input of layerInfo (unless
% varargin is used).
%
% Author: Alexandre D. Simard                     Creation date: 11/11/2014
% Example
%         CPSinfo = CPS([0,-0.8,-1.2,-2,-1.2,-5,-1.2,...
%                        0, 0.8, 1.2, 2, 1.2, 5, 1.2],...
%                       [-5,-5,-5,-4,-12,-10,-100,...
%                         5, 5, 5, 4, 12, 10, 100],...
%                       [layerMap.N,layerMap.Np,layerMap.Npp,layerMap.V1,
%                        layerMap.M1,layerMap.V2,layerMap.M2,...
%                        layerMap.P,layerMap.Pp,layerMap.Ppp,layerMap.V1,
%                        layerMap.M1,layerMap.V2,layerMap.M2],...
%                        'routinglayer',{layerMap.P},'SPPgroundlayer',
%                       {layerMap.N,layerMap.Np,layerMap.Npp});
%
%
%     See also PLACECPS

%% Read Options

cpsvar.routinglayer = [];
cpsvar.SPPgroundlayer = [];
cpsvar.IndBridg = [];
cpsvar = ReadOptions(cpsvar, varargin{:});

if iscell(cpsvar.routinglayer)
  cpsvar.routinglayer = [cpsvar.routinglayer{:}];
  cpsvar.routingdtype = cpsvar.routinglayer(2,:);
  cpsvar.routinglayer = cpsvar.routinglayer(1,:);
else
  cpsvar.routinglayer = layerInfo(1,end);
  cpsvar.routingdtype = layerInfo(2,end);
end

if iscell(cpsvar.SPPgroundlayer)
  cpsvar.SPPgroundlayer = [cpsvar.SPPgroundlayer{:}];
  cpsvar.SPPgrounddtype = cpsvar.SPPgroundlayer(2,:);
  cpsvar.SPPgroundlayer = cpsvar.SPPgroundlayer(1,:);
else
  cpsvar.SPPgrounddtype = [];
end

%% Creating the coplanar strip
layer = layerInfo(1,:);
dtype = layerInfo(2,:);

% Arguments validation
rows = max([size(Xin, 1), size(Xout, 1), size(layer, 1), size(dtype, 1)]);
[CPSWG, Xin, Xout, layer, dtype,  cpsvar.IndBridg] = NumberOfRows(rows, CPSWG, Xin, Xout, layer, dtype,cpsvar.IndBridg);


% Calculations
w = abs(Xout-Xin);
shift = Xout/2 + Xin/2;
outCPS(rows, 1) = struct('w', [], 'shift', [], 'layer', [], 'dtype', [], 'routinglayer',[], 'routingdtype', [], 'SPPgroundlayer', [], 'SPPgrounddtype', [] );

for row = 1 : rows
  % outCPS fields
  outCPS(row).CPSWG = CPSWG(row);
  outCPS(row).w = w(row, :);
  outCPS(row).shift = shift(row, :);
  outCPS(row).layer = layer(row, :);
  outCPS(row).dtype = dtype(row, :);
  outCPS(row).routinglayer = cpsvar.routinglayer;
  outCPS(row).routingdtype = cpsvar.routingdtype;
  outCPS(row).SPPgroundlayer = cpsvar.SPPgroundlayer;
  outCPS(row).SPPgrounddtype = cpsvar.SPPgrounddtype;
  if ~isempty(cpsvar.IndBridg)
    outCPS(row).IndBridg = cpsvar.IndBridg(row);
  end
end

end


