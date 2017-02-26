function outVias = Vias(wi, len, shiftx, shifty, layerinfo,varargin)
% Create Vias information structure
%Author: Alexandre D. Simard                                     Creation date: 11/10/2014
%
% 
%     See also PLACEVias

%%
viavar.probesperiod = [];
viavar.WGinfo = [];
viavar = ReadOptions(viavar, varargin{:});

layer = layerinfo(1,:);
dtype = layerinfo(2,:);


rows = max([size(wi, 1), size(len, 1), size(shiftx, 1), size(shifty, 1), size(layer, 1), size(dtype, 1)]);
[wi, len, shiftx, shifty, layer, dtype] = NumberOfRows(rows, wi, len, shiftx, shifty, layer, dtype);


outVias(rows, 1) = struct('w', [], 'len', [], 'shiftx', [], 'shifty', [], 'layer', [], 'dtype', []);

    for row = 1 : rows
      % outVias fields
      outVias(row).w = wi(row, :);
      outVias(row).len = len(row, :);
      outVias(row).shiftx = shiftx(row, :);
      outVias(row).shifty = shifty(row, :);
      outVias(row).layer = layer(row, :);
      outVias(row).dtype = dtype(row, :);
      if ~isempty(viavar.probesperiod)
          outVias(row).probesperiod = viavar.probesperiod;
      end
      if ~isempty(viavar.WGinfo)
          outVias(row).WGinfo = viavar.WGinfo;
      end      
    end

end


