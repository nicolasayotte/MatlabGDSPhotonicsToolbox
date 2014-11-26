function [ostruc] = refrename(istruc, osname, nsname)
%function [ostruc] = refrename(istruc, osname, nsname)
%
% refrename :  replaces a referenced structure name in all
%              sref and aref elements that contain it.
%
% istruc :  input gds_structure object
% osname :  old referenced structure name
% nsname :  new referenced structure name
% ostruc :  output gds_structure object

% initial version, December 2012, Ulf Griesmann

ostruc = istruc;

% look for reference elements
for k = 1:length(ostruc.el)
   if is_ref(ostruc.el{k})
      E = ostruc.el{k};         
      if strcmp(osname, E.sname)    % check referenced structure name
         E.sname = nsname;          % replace name
         ostruc.el{k} = E;
      end
   end
end

return
