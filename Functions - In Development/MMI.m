function outMMI = MMI(wi, len, tapl, ff, layer, dtype)
%MICRoutMMI Create a MMI information structure
%Author: Alexandre D. Simard                                     Creation date: 04/08/2014
%
% 
%     See also PLACEMMI

rows = max([size(wi, 1), size(len, 1), size(tapl, 1), size(ff, 1), size(layer, 1), size(dtype, 1)]);
[wi, len, tapl, ff, layer, dtype] = NumberOfRows(rows, wi, len, tapl, ff, layer, dtype);


outMMI(rows, 1) = struct('w', [], 'len', [], 'tapl', [], 'ff', [], 'layer', [], 'dtype', []);

    for row = 1 : rows
      % outMMI fields
      outMMI(row).w = wi(row, :);
      outMMI(row).len = len(row, :);
      outMMI(row).tapl = tapl(row, :);
      outMMI(row).ff = ff(row, :);
      outMMI(row).layer = layer(row, :);
      outMMI(row).dtype = dtype(row, :);
    end

end


