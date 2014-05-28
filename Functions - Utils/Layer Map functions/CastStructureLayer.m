function st = CastStructureLayer(st, mapLayer, mapDatatype, log)
%CASTSTRUCTURELAYER Cast the layers from a structure to other layers.
%
%     ARGUMENT NAME     SIZE        DESCRIPTION
%     st                1           gds_structure
%     mapLayer          sparse      cast matrix for layers
%     mapDatatype       sparse      cast matrix for datatypes
%     log               1           log object
%
%     See also READLAYERMAP, CASTLAYERMAP, CASTDEFINEMAP, CASTPOSTPROCESSING.

log.write('\t\t\t%s  -  Casting layers from structure %s\n', log.time(), sname(st));

% Finding the elements
refs = find(st, @(el) is_etype(el, 'sref') || is_etype(el, 'aref'));
bounds = find(st, @(el) is_etype(el, 'boundary') || is_etype(el, 'path'));
texts = find(st, @(el) is_etype(el, 'text'));

% Casting functions
boundariessFun = @(el) set(el, ...
  'layer', mapLayer(get(el, 'layer') + 1, get(el, 'dtype') + 1),...
  'dtype', mapDatatype(get(el, 'layer') + 1, get(el, 'dtype') + 1));

textsFun = @(el) set(el, 'layer', mapLayer(get(el, 'layer') + 1, 1));

% Doing the cast
bounds = cellfun(boundariessFun, bounds, 'UniformOutput', false);
texts = cellfun(textsFun, texts, 'UniformOutput', false);

% Deleting layer 0 dtype 0 - default cast for map entries that do not exist
bounds = bounds(cellfun(@(el) ~((get(el, 'layer') == 0) & (get(el, 'dtype') == 0)), bounds));
texts = texts(cellfun(@(el) ~((get(el, 'layer') == 0) & (get(el, 'dtype') == 0)), texts));

% Save in structure
st = set(st, 'el', [refs, bounds, texts]);

end