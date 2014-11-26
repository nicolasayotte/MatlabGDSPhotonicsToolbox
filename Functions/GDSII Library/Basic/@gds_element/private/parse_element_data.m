function data = parse_element_data(etype, propval);
%function data = parse_element_data(etype, propval);
% 
% parses the property value argument list
% of the gds_element constructor and returns
% arguments and default values in a structure

% create a new internal data structure
data.internal = new_internal(etype);

% parse the list of property / value pairs
ipropval = {};
for idx = 1:2:length(propval)

   % get next property/value pair
   elproperty = propval{idx};
   elvalue = propval{idx+1};
   
   % check if property is stored outside the internal structure
   if ~isempty(elvalue)
      if is_not_internal(elproperty) % xy, prop, text
         data.(elproperty) = elvalue;
      else
         ipropval = [ipropval, {elproperty,elvalue}];
      end
   end

end

% store values to internal structure
if ~isempty(ipropval)
   data.internal = set_element_data(data.internal, ipropval);
end

return
