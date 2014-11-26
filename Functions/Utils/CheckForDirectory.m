function CheckForDirectory(cellname)
%CHECKFORDIRECTORY Ensure that the Cells directory and following hierarchy exists.


index = find((cellname == '/') | (cellname == '\'), 1, 'last');
if(~isempty(index))
   tdir = cellname(1:index - 1);
   
   warning('off','all');
   mkdir(tdir);
   warning('on','all');
end

end