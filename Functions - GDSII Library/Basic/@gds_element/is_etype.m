function [is] = is_etype(gelm, etype);
%function [is] = is_etype(gelm, etype);
%
% tests the type of a GDS element
%
% gelm :   a GDS element
% etype :  a string with element type (boundary, path, node, ...)
% is :     1 if the element is of type 'etype'
%          0 otherwise

is = strcmp(get_etype(gelm.data.internal), lower(etype));

return
