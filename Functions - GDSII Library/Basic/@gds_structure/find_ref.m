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

   % find the reference elements
   reidx = cellfun(@(x)is_ref(x), gstruct.el);

   % and get their referenced structure names (need not be unique)
   rnam = cellfun(@(x)x.sname, gstruct.el(reidx), 'UniformOutput',0);
   
end
