function gelp = subsref(gstruct, ins);
%function gelp = subsref(gstruct, ins);
%
% subscript reference method for the gds_structure class
%
% gstruct :  a gds_structure object
% ins :      an array index reference structure
% gelp :     a gds_element object or 
%            a cell array of the indexed gds_element objects
%            or a structure property when structure name
%            referencing is used

% Ulf Griesmann, NIST, June 2011

switch ins.type
 
 case '()'
    
    idx = ins.subs{:};
    if ischar(idx) && idx == ':'
       gelp = gstruct.el(1:end);
    elseif length(idx) == 1 
       gelp = gstruct.el{idx};  % return element
    else
       gelp = gstruct.el(idx);  % return cell array of elements
    end

 case '.'
  
    switch ins.subs
       
     case 'sname'
        gelp = gstruct.sname;
        
     case 'cdate'
        gelp = gstruct.cdate;
        
     case 'mdate'
        gelp = gstruct.mdate;
        
     otherwise
        error('gds_structure.subsref :  invalid structure property.');
    end
    
 otherwise
    error('gds_structure.subsref :  invalid indexing type.');

end
  
return  
