function pelm = poly_box(belm);
%function pelm = poly_box(belm);
%
% creates a boundary element with the same shape 
% as a box element.
%
% belm :  input box element
% pelm :  output boundary element

% Initial version, Ulf Griesmann, December 2011

% check if input is a box
if ~strcmp(get_etype(belm.data.internal), 'box')
   error('gds_element.poly_box :  input must be box element.');
end

% copy element properties to new internal structure
data.internal = new_internal('boundary');
data.xy = belm.data.xy;
if isfield(belm, 'prop')
   data.prop = belm.data.prop;
end

plist = {'layer',get_element_data(belm.data.internal,'layer'), ...
         'dtype',get_element_data(belm.data.internal,'btype')};
if has_property(belm.internal, 'elflags')
   plist = [plist, {'elflags',get_element_data(belm.data.internal,'elflags')}];
end
if has_property(belm.internal, 'plex')
   plist = [plist, {'plex',get_element_data(belm.data.internal,'plex')}];
end
data.internal = set_element_data(data.internal, plist);

% create new element
pelm = gds_element([], data);

return
