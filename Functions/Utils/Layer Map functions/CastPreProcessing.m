function st = CastPreProcessing(st, mapName, mapType, log)
%CASTPOSTPROCESSING Layer copying and/or boolean operations for specific layer maps.
%
%
%
%     See also CASTDEFINEMAP, READLAYERMAP, CASTLAYERMAP, CASTSTRUCTURELAYER.

hasInstructions = true;
if(strcmpi(mapType, 'input'))
  switch mapName
    case 'UoW'
      %          st = cellfun(@(x)SubstractLayer(x, [103, 2], [103,3], [1, 0]), st);
      %          st = cellfun(@(x)OffsetLayer(x, 2, 1, 3.5, 'jtMiller'), st);
    otherwise
      hasInstructions = false;
  end
else
  switch mapName
    case 'UoW'
      % This operation cuts all the area on [1, 0] which is enclosed in the
      % [2, 1] layer and puts it on the [104, 2] layer. It leaves all the area on
      % on [1, 0] NOT surrounded by [2, 1] on its original layer. This is a selective
      % layer casting operation.
      
      st = AndLayer(st, [1, 0], [2, 1], [104, 3]);
      st = AndLayer(st, [1, 0], [3, 1], [104, 2]);
      % Then cast layer [104, 2] and [104, 3] onto other layers in the standard
      % CastLayerMap operation
    otherwise
      hasInstructions = false;
  end
end

if hasInstructions
  log.write('\t\t\t%s  -  Pre-Processing for structure %s\n', log.time(), sname(st));
end

end



function st = CopyLayer(st, sourceLayer, targetLayer)
refEls = find(st, @(el) is_etype(el, 'sref') || is_etype(el, 'aref'));
boundEls = find(st, @(el) is_etype(el, 'boundary') || is_etype(el, 'path'));
textEls = find(st, @(el) is_etype(el, 'text'));

sourceMask = cellfun(@(el) ((get(el, 'layer') == sourceLayer(1)) && (get(el, 'dtype') == sourceLayer(2))), boundEls);
sourceEls = boundEls(sourceMask);
if(~isempty(sourceEls))
  boundFun = @(el) set(el, 'layer', targetLayer(1), 'dtype', targetLayer(2));
  targetEls = cellfun(boundFun, sourceEls, 'UniformOutput', false);
else
  targetEls = {};
end
st = set(st, 'el', [refEls, boundEls, targetEls, textEls]);
st = set(st, 'numel', length([refEls, boundEls, targetEls, textEls]));
end



function st = CastLayer(st, sourceLayer, targetLayer)
refEls = find(st, @(el) is_etype(el, 'sref') || is_etype(el, 'aref'));
boundEls = find(st, @(el) is_etype(el, 'boundary') || is_etype(el, 'path'));
textEls = find(st, @(el) is_etype(el, 'text'));

sourceMask = cellfun(@(el) ((get(el, 'layer') == sourceLayer(1)) && (get(el, 'dtype') == sourceLayer(2))), boundEls);
sourceEls = boundEls(sourceMask);
boundEls = boundEls(~sourceMask);

boundFun = @(el) set(el, 'layer', targetLayer(1), 'dtype', targetLayer(2));
targetEls = cellfun(boundFun, sourceEls, 'UniformOutput', false);

st = set(st, 'el', [refEls, boundEls, targetEls, textEls]);
st = set(st, 'numel', length([refEls, boundEls, targetEls, textEls]));
end



function st = AndLayer(st, sourceLayer, andLayer, targetLayer, varargin)

options.discardRemains = false;
options = ReadOptions(options, varargin{:});

refEls = find(st, @(el) is_etype(el, 'sref') || is_etype(el, 'aref'));
boundEls = find(st, @(el) is_etype(el, 'boundary') || is_etype(el, 'path'));
textEls = find(st, @(el) is_etype(el, 'text'));

sourceMask = cellfun(@(el) ((get(el, 'layer') == sourceLayer(1)) && (get(el, 'dtype') == sourceLayer(2))), boundEls);
andMask = cellfun(@(el) ((get(el, 'layer') == andLayer(1)) && (get(el, 'dtype') == andLayer(2))), boundEls);

sourceEls = boundEls(sourceMask);
andEls = boundEls(andMask);
boundEls = boundEls(~(sourceMask | andMask));

if(all([~isempty(sourceEls), ~isempty(andEls)]))
  sourceEl = MergeElements(sourceEls);
  andEl = MergeElements(andEls);
  
  targetEl = {poly_bool(sourceEl, andEl, 'and', 'layer', targetLayer(1), 'dtype', targetLayer(2))};
  partialEl = {poly_bool(sourceEl, andEl, 'notb')};
  
  targetEl = {CheckForLargePolygons(targetEl{1})};
  partialEl = {CheckForLargePolygons(partialEl{1})};

  
  targetMask = true(1, length(targetEl));
  for ii = 1 : length(targetEl)
    if(isempty(targetEl{ii}.xy))
    targetMask(ii) = false;
    end
  end
  targetEl = targetEl(targetMask);
  
  partialMask = true(1, length(partialEl));
  for ii = 1 : length(partialEl)
    if(isempty(partialEl{ii}.xy))
      partialMask(ii) = false;
    end
  end
  partialEl = partialEl(partialMask);
  
  if ~options.discardRemains
    boundEls = [boundEls, partialEl];
  end
else
  targetEl = [sourceEls, andEls];
end

st = set(st, 'el', [refEls, boundEls, targetEl, textEls]);
st = set(st, 'numel', length([refEls, boundEls, targetEl, textEls]));
end


