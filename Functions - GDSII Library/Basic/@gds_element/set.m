function s = set(gelm, varargin);
%function s = set(gelm, varargin);
%
% set property method for GDS elements
%

if (length (varargin) < 2 || rem (length (varargin), 2) ~= 0)
   error ('gds_element.set :  expecting property/value pair(s).');
end

s = gelm;

% parse the list of property / value pairs
ipropval = {};
for idx = 1:2:length(varargin)

   % get next property/value pair
   elproperty = varargin{idx};
   elvalue = varargin{idx+1};
   
   % check if property is stored outside the internal structure
   if ~isempty(elvalue)
      if is_not_internal(elproperty) % xy, prop, text
         s.data.(elproperty) = elvalue;
      else
         ipropval = [ipropval, {elproperty,elvalue}];
      end
   end

end

% store values to internal structure
if ~isempty(ipropval)
   s.data.internal = set_element_data(s.data.internal, ipropval);
end

return
