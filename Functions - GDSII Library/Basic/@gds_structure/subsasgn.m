function gstruc = subsasgn(gstruc, ins, val);
%function gstruc = subsasgn(gstruc, ins, val);
%
% Subscript assign method for the gds_element class
% Enables addressing elements in a structure using
% array indexing.
%
% gstruc :  gds_structure object to be modified
% ins :     index structure
% val :     element

% Ulf Griesmann, NIST, November 2011

switch ins.type
  
 case '()'
    idx = ins.subs{:};
    gstruc.el{idx} = val;
    gstruc.numel = gstruc.numel + 1;

 case '.'
    if strcmp(ins.subs, 'sname') || strcmp(ins.subs, 'cdate') || strcmp(ins.subs, 'mdate')
       gstruc.(ins.subs) = val;
    else
       error(sprintf('invalid GDS structure property >> %s <<', ins.subs));
    end

 otherwise
    error('gds_structure.subsasgn :  unsupported indexing type.');
    
end

return
