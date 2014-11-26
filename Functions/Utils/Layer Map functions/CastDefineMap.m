function [mapLayer, mapDatatype] = CastDefineMap(mapName, mapType)
%CASTDEFINEMAP Define the maps for the layers and datatypes for use in CastLayerMap.
%
%     mapLayer is a sparse matrix where you look at the mapLayer(layer, dataType)
%     index and it gives you layer in the other layer map.
%     mapDatatype is a sparse matrix where you look at the mapDatatype(layer, dataType)
%     index and it gives you datatype in the other layer map.
%
%     See also READLAYERMAP, CASTLAYERMAP, CASTPOSTPROCESSING, CASTSTRUCTURELAYER.

switch mapName
   case 'UoW'
      layerGeneral = [1, 91, 92, 94, 103, 103, 103];
      datatypeGeneral = [0, 0, 0, 0, 0, 1, 2];
      layerOther = [1, 99, 10, 26, 31, 32, 33];
      datatypeOther = [0, 0, 0, 0, 0, 0, 0];
   case 'ulaval'
      error('The layer map cannot be ulaval. Use another layer map.')
end

switch mapType
   case 'output'
      mapLayer = sparse(layerGeneral+1, datatypeGeneral+1, layerOther, 255, 255);
      mapDatatype = sparse(layerGeneral+1, datatypeGeneral+1, datatypeOther, 255, 255);
   case 'input'
      mapLayer = sparse(layerOther+1, datatypeOther+1, layerGeneral, 255, 255);
      mapDatatype = sparse(layerOther+1, datatypeOther+1, datatypeGeneral, 255, 255);
end
