function PlotPolygons(obj, type)

switch type
   case 'element'
      xy = obj.xy;
      layers = length(xy);
      color = get(obj, 'layer') + 0.1 * get(obj, 'dtype');
      for layer = layers : -1 : 1
         patch(xy{layer}(:,1), xy{layer}(:,2), color);
      end

   case 'structure'
      elements = find(obj, @(el) is_etype(el, 'boundary') || is_etype(el, 'path'));
      for el = 1 : length(elements)
         element = elements{el};
         xy = element.xy;
         color = get(element, 'layer') + 0.1 * get(element, 'dtype');
         layers = length(xy);
         for layer = layers : -1 : 1
            patch(xy{layer}(:,1), xy{layer}(:,2), color);
         end
      end
end