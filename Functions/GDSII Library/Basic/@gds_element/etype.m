function [type] = etype(gelm);
%function [type] = etype(gelm);
%
% returns the type of a GDS element
%
% gelm :   a GDS element
% type :  a string with element type (boundary, path, node, ...)

type = get_etype(gelm.data.internal);

return
