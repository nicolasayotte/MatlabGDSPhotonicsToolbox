function guide = Waveguide(w, layerInfo, r, sp)

%WAVEGUIDE Create a waveguide information structure
%Author : Nicolas Ayotte                                   Creation date : 21/03/2014
%
% 
%     guide = Waveguide(widths, layers, minimumCurvingRadius, minimumSpacing)
%
%     This function implements the naming convention of the fields for a Waveguide. 
%     The layer information is meant to come from a layerMap structure created
%     by the ReadLayerMap function.
%
% 
%     FIELD NAME     SIZE        DESCRIPTION
%     'w'            1 x m       width of each layer
%     'layer'        1 x m       layer number
%     'dtype'        1 x m       datatype
%     'sp'           1           minimum center-to-center spacing between waveguides
%     'r'            1           minimum radius of curvature
%
%     See also Taper, FiberArray, ReadLayerMap

guide = struct(...
  'w', w, ...
  'layer', layerInfo(1, : ), ...
  'dtype', layerInfo(2, : ), ...
  'sp', sp, ...
  'r', r);

end
