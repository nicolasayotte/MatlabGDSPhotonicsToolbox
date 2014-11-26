function [gelm] = plus(gelm1, gelm2);
%function [gelm] = plus(gelm1, gelm2);
%
% Overloads the '+' operator for the gds_element class.
% Can be used to combine to simple or compound boundary, path,
% or sref elements into a new compound element. All properties
% are inherited from gelm1.
%
% gelm1 :  input boundary, path, or sref element 1
% gelm2 :  input boundary, path, or sref element 2
% gelm  :  compound boundary path or sref element
%          on the same layer as gelm1.

% Ulf Griesmann, NIST, November 2012

t1 = get_etype(gelm1.data.internal);
t2 = get_etype(gelm1.data.internal);
if ~strcmp(t1, t2)
   error('gds_element.plus :  arguments of + must have the same type.');
end

switch t1
  
  case {'boundary', 'path'}
     gelm = gelm1;
     gelm.data.xy = [gelm1.data.xy, gelm2.data.xy];
       
  case 'sref'
     gelm = gelm1;
     gelm.data.xy = [gelm1.data.xy; gelm2.data.xy];
  
  otherwise
     error('gds_element.plus :  input must be boundary, sref, or path element.');
end

return

