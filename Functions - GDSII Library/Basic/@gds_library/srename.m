function [olib] = srename(ilib, osname, nsname)
%function [olib] = srename(ilib, osname, nsname)
%
% srename :  renames a structure and all references to 
%            the structure in a library.
%
% ilib :    input gds_library object
% osname :  old referenced structure name
% nsname :  new referenced structure name
% olib :    output gds_library object

% initial version, December 2012, Ulf Griesmann

olib = ilib;

% find the structure that needs to be replaced
sidx =  1;
while sidx <= length(ilib.st)  
   if strcmp(osname, sname(ilib.st{sidx}))
      break
   end
   sidx = sidx + 1;
end

% rename the structure
olib.st{sidx} = rename(ilib.st{sidx}, nsname);

% rename all references to the renamed structure
for k = setdiff(1:length(olib.st), sidx)
   olib.st{k} = refrename(ilib.st{k}, osname, nsname);
end

return
