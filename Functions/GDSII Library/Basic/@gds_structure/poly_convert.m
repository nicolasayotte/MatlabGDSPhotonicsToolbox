function [cstruc] = poly_convert(gstruc);
%function [cstruc] = poly_convert(gstruc);
% 
% converts path or box elements into 
% equivalent boundary elements. Text and
% node elements are removed.
% 
% gstruc :   input gds_structure object
% cstruc :   output gds_structure object
%
% Example:
%        gstruc = poly_convert(gstruc);
%
% converts all path and box elements in gstruc into boundary 
% elements.
%
% NOTE:
% The output structure has the same name as the input
% structure !

% Initial version, Ulf Griesmann, December 2011

% copy structure
cstruc = gstruc;
m = 1;

% this isn't elegant, but I couldn't think of a better way yet ..
for k = 1:length(gstruc.el)    % loop over elements
  
   switch etype(gstruc.el{k})
     case 'path'
        cstruc.el{m} = poly_path(gstruc.el{k}); 
        m = m + 1;
     case 'box'
        cstruc.el{m} = poly_box(gstruc.el{k}); 
        m = m + 1;
     case {'text','node'}
        % ignore - don't copy   
     otherwise
        cstruc.el{m} = gstruc.el{k};    
        m = m + 1;
   end

end

% shorten if text elements were removed
if m <= length(gstruc.el)
   cstruc.el(m:end) = [];
end

return
