function display(glib);
%function display(glib);
%
% display method for GDS libraries
%

% print variable name
fprintf('%s = \n\n', inputname(1));
fprintf('Library:\n');
fprintf('lname         :  %s\n', glib.lname);
fprintf('Database unit :  %g m\n', glib.dbunit);
fprintf('User unit     :  %g m\n', glib.uunit);
fprintf('Structures    :  %d\n', glib.numst);
for k = 1:glib.numst
   fprintf('%6d ... %s (%d)\n', k, sname(glib.st{k}), numel(glib.st{k}));
end
fprintf('\n');
return
