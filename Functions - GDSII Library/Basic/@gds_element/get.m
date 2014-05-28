function s = get(gelm, p);
%function s = get(gelm, p);
%
% get property method for GDS elements
%

% called with only one argument, return a structure with all data
if nargin == 1
   s = gelm.data;
   return
end

if ischar(p)

   switch p
        
     case 'etype'
        s = get_etype(gelm.data.internal);

     case {'xy','path','prop','text'}
        s = gelm.data.(p);
            
     otherwise
        s = get_element_data(gelm.data.internal, p);
   end
     
else
   error('gds_element.get :  property must be a string.');
end
  
return
