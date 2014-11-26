function ommi = MMI(w, len, tapl, ff, layer, dtype)
%MMI Create a MMI information structure
%Author: Alexandre D. Simard                                Creation date: 04/08/2014
%
%
%     See also PLACEMMI, TAPER, PLACERECT, PLACEARC.

rows = max([size(w, 1), size(len, 1), size(tapl, 1), size(ff, 1), size(layer, 1), size(dtype, 1)]);

%% Argument validation
[w, len, tapl, ff, layer, dtype] = NumberOfRows(rows, w, len, tapl, ff, layer, dtype);


ommi(rows, 1) = struct('w', [], 'len', [], 'tapl', [], 'ff', [], 'layer', [], 'dtype', []);
for row = 1 : rows
   ommi(row).w = w(row, :);
   ommi(row).len = len(row, :);
   ommi(row).tapl = tapl(row, :);
   ommi(row).ff = ff(row, :);
   ommi(row).layer = layer(row, :);
   ommi(row).dtype = dtype(row, :);
end

end


