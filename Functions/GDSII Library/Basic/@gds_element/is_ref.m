function [is] = is_ref(gelm);
%function [is] = is_ref(gelm);
%
% tests if the element is a reference element
%
% gelm :   a GDS element
% is :     1 if the element is 'sref' or 'aref' element
%          0 otherwise

is = isref(gelm.data.internal);

return
