function prop = subsref(gelm, ins);
%function prop = subsref(gelm, ins);
%
% subscript reference method for the gds_element class
% This method allows class properties to be addressed using
% structure field name indexing. The xy property of compound 
% elements can also be accessed with array indexing.
% The element type cannot be changed.
%
% gelm :   a gds_element object
% ins :    an array index reference structure
% prop :   the index property

% Ulf Griesmann, NIST, June 2011, July 2013

switch ins.type
 
 case '.'
    if is_not_internal(ins.subs)
       prop = gelm.data.(ins.subs);
    else
       prop = get_element_data(gelm.data.internal, ins.subs);
    end
 
 case '()'
    idx = ins.subs{:};
    
    switch get_etype(gelm.data.internal)
      
      case {'boundary','path'}
         if length(idx) == 1 && idx(1) ~= ':'
           prop = gelm.data.xy{idx};  % return polygon
         else
           prop = gelm.data.xy(idx);  % return cell array of polygons
         end
 
      otherwise
         prop = gelm.data.xy(idx,:);  % location

    end
    
 otherwise
    error('gds_element.subsref :  invalid indexing type.');

end
  
return  
