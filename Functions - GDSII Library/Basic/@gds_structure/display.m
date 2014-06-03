function display(gstruc);
%function display(gstruc);
%
% display method for GDS structures
%

   % check argument
   if nargin == 0, error('gds_structure.display :  missing argument.'); end;

   % print variable name
   fprintf('%s = \n\n', inputname(1));
   if numel(gstruc.el) == 1
      fprintf('Structure (1 element):\n');
   else
      fprintf('Structure (%d elements):\n', numel(gstruc.el));
   end
   fprintf('sname = %s\n', gstruc.sname);
   fprintf('cdate = %d-%d-%d, %02d:%02d:%02d\n', gstruc.cdate);
   if ~isempty(gstruc.mdate)
      fprintf('mdate = %d-%d-%d, %02d:%02d:%02d\n', gstruc.mdate);
   end
   fprintf('\n');

end
