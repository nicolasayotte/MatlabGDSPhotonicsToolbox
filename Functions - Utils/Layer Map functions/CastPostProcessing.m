function st = CastPostProcessing(st, mapName, mapType, log)
%CASTPOSTPROCESSING Layer copying and/or boolean operations for specific layer maps.
% 
%     
% 
%     See also CASTDEFINEMAP, READLAYERMAP, CASTLAYERMAP, CASTSTRUCTURELAYER.

if(strcmpi(mapType, 'input'))
  switch mapName
    case 'IMEC_something'
%       st = cellfun(@(x)CopyLayer(x, [1, 1], [0, 0], [2, 2], [0, 1]), st);
      % st = cellfun(@(x)OffsetLayer(x, 2, 1, 3.5, 'jtMiller'), st);
    otherwise
      log('\nNo post-processing instructions.\n');
  end
end

end



function st = CopyLayer(st, layer, dtype, layer2, dtype2)
refs = find(st, @(el) is_etype(el, 'sref') || is_etype(el, 'aref'));
bounds = find(st, @(el) is_etype(el, 'boundary') || is_etype(el, 'path'));
texts = find(st, @(el) is_etype(el, 'text'));

els = cell(1, 0);
for ii = 1: length(ii)
  targets = bounds(cellfun(@(el) ~((get(el, 'layer') == layer(ii)) & (get(el, 'dtype') == dtype(ii))), bounds));
  fun = @(el) set(el, 'layer', layer2(ii), 'dtype', dtype2(ii));
  targets = cellfun(fun, targets, 'UniformOutput', false);
  els = [els, targets];
end

st = set(st, 'el', [refs, bounds, els, texts]);
end



function st = MergeLayer(st, layer, dtype, layer2, dtype2)

refs = find(st, @(el) is_etype(el, 'sref') || is_etype(el, 'aref'));
bounds = find(st, @(el) is_etype(el, 'boundary') || is_etype(el, 'path'));
texts = find(st, @(el) is_etype(el, 'text'));
els = cell(1, 0);

for ii = 1: length(ii)
  targets = bounds(cellfun(@(el) ~((get(el, 'layer') == layer(ii)) & (get(el, 'dtype') == dtype(ii))), bounds));
  fun = @(el) set(el, 'layer', layer2(ii), 'dtype', dtype2(ii));
  targets = cellfun(fun, targets, 'UniformOutput', false);
  els = [els, targets];
end

st = set(st, 'el', els);
end