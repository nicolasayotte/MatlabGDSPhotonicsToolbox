%
% script to make .mex files
%

% low level functions
fprintf('\n\n>>>>>\n');
fprintf('>>>>>  Compiling mex functions for low-level i/o on MATLAB ...\n');
fprintf('>>>>>\n');

cd Basic/gdsio
mex -O gds_open.c mexfuncs.c
mex -O gds_close.c mexfuncs.c
mex -O gds_ftell.c mexfuncs.c
mex -O gds_structdata.c gdsio.c mexfuncs.c 
mex -O gds_libdata.c gdsio.c mexfuncs.c
mex -O gds_beginstruct.c gdsio.c mexfuncs.c
mex -O gds_endstruct.c gdsio.c mexfuncs.c
mex -O gds_beginlib.c gdsio.c mexfuncs.c
mex -O gds_endlib.c gdsio.c mexfuncs.c
mex -O gds_write_element.c gdsio.c mexfuncs.c
mex -O gds_read_element.c gdsio.c mexfuncs.c mxlist.c
mex -O gds_record_info.c gdsio.c mexfuncs.c

cd ../@gds_element/private
mex -O poly_iscwmex.c
mex -O -I../../gdsio isref.c
mex -O -I../../gdsio get_etype.c
mex -O -I../../gdsio is_not_internal.c
mex -O -I../../gdsio new_internal.c
mex -O -I../../gdsio has_property.c
mex -O -I../../gdsio get_element_data.c ../../gdsio/mexfuncs.c
mex -O -I../../gdsio set_element_data.c ../../gdsio/mexfuncs.c

cd ../../../Structures/private
mex -O datamatrixmex.c

% Boolean functions
fprintf('\n\n>>>>>\n');
fprintf('>>>>>  Compiling Boolean set algebra functions (Clipper)...\n');
fprintf('>>>>>\n\n');

% for Clipper library
cd ../../Boolean
makemex;

% back up
cd ..

