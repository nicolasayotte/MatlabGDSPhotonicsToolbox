function rnam = find_ref(gstruct);
%function rnam = find_ref(gstruct);
%
% A method that finds and returns the names of all structures
% referenced in a structure
%
% gstruct :  a gds_structure object
% rnam :     a cell array of structure names referenced by gstruct 
%

% Ulf Griesmann, NIST, November 2011

rnam = {};
for k=1:length(gstruct.el)
   if is_ref(gstruct.el{k}) && ~ismember(gstruct.el{k}.sname, rnam)
      rnam{end+1} = gstruct.el{k}.sname;
   end
end
  
return  
