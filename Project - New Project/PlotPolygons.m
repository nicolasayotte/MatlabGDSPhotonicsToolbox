function PlotPolygons(element)

layers = length(element.xy);
for layer = layers : -1 : 1
   polygons = element.xy{layer};
   polyCount = length(polygons);
   if(~isempty(polygons))
      for polygon = 1 : polyCount
         patch(polygons{polygon}(:,1), polygons{polygon}(:,2), layer);
      end
   end
end

end