function [gst] = gds_read_struct(gf, uunit, dbunit)
%
% read all elements contained in a structure and return 
% a gds_structure object 
%

% renamed 'gdsii_read_struct' --> gds_read_struct' and rewritten
% for the new C-based low level I/O. U. Griesmann, Jan. 2013

% read structure header data
[sname, cdate, mdate] = gds_structdata(gf);

% read all elements belonging to it
elist = {};
while 1
  
   % read next record header (ignore record length) 
   rtype = gds_record_info(gf);
   
   % ENDSTR - reached end of structure
   if (rtype == 1792)
      break
   end
  
   % if not, read element data
   data = gds_read_element(gf, rtype, dbunit/uunit);
   
   % create element object and add to cell array
   elist{end+1} = gds_element([], data);
  
end

% create a new GDS structure
gst = gds_structure(sname, elist);
gst = set(gst, 'cdate',cdate, 'mdate',mdate);

return
