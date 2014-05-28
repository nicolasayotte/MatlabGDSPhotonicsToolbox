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
   case 'TEST_fab'
      layerGeneral = [1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 7, 8, 9, 11, 11, 11, 12, 12, 12, 13, 14, 21, 21, 21, 21, 22, 22, 22, 22, 22, 23, 29, 29, 31, 32, 32, 32, 33, 33, 33, 33, 91, 92, 93, 101, 102, 102];
      datatypeGeneral = [0, 1, 2, 3, 0, 1, 2, 3, 0, 1, 2, 3, 0, 0, 0, 1, 2, 3, 1, 2, 3, 1, 1, 1, 3, 4, 5, 1, 2, 3, 4, 5, 1, 1, 2, 0, 3, 4, 0, 0, 1, 2, 3, 0, 0, 0, 0, 0, 1];
      layerOther = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 34, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 26, 27, 28, 29, 30, 31, 32, 33, 25, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50];
      datatypeOther = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
end

switch mapType
  case 'output'
    mapLayer = sparse(layerGeneral+1, datatypeGeneral+1, layerOther, 255, 255);
    mapDatatype = sparse(layerGeneral+1, datatypeGeneral+1, datatypeOther, 255, 255);
  case 'input'
    mapLayer = sparse(layerOther+1, datatypeOther+1, layerGeneral, 255, 255);
    mapDatatype = sparse(layerOther+1, datatypeOther+1, datatypeGeneral, 255, 255);
end
