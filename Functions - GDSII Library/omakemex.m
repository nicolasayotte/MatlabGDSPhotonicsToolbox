%
% script to make .mex files on Octave/Windows
%

% low level functions
fprintf('\n\n>>>>>\n');
fprintf('>>>>>  Compiling mex functions for low-level i/o on Octave/Windows ...\n');
fprintf('>>>>>\n');

setenv('CFLAGS', '-O3 -fomit-frame-pointer -march=native -mtune=native');
setenv('CXXFLAGS', '-O3 -fomit-frame-pointer -march=native -mtune=native');

cd Basic/gdsio
mex gds_open.c mexfuncs.c
mex gds_close.c mexfuncs.c
mex gds_ftell.c mexfuncs.c
mex gds_structdata.c gdsio.c mexfuncs.c 
mex gds_libdata.c gdsio.c mexfuncs.c
mex gds_beginstruct.c gdsio.c mexfuncs.c
mex gds_endstruct.c gdsio.c mexfuncs.c
mex gds_beginlib.c gdsio.c mexfuncs.c
mex gds_endlib.c gdsio.c mexfuncs.c
mex gds_write_element.c gdsio.c mexfuncs.c
mex gds_read_element.c gdsio.c mexfuncs.c mxlist.c
mex gds_record_info.c gdsio.c mexfuncs.c
system('del *.o');

cd ../@gds_element/private
mex poly_iscwmex.c
mex -I../../gdsio isref.c
mex -I../../gdsio get_etype.c
mex -I../../gdsio is_not_internal.c
mex -I../../gdsio new_internal.c
mex -I../../gdsio has_property.c
mex -I../../gdsio get_element_data.c ../../gdsio/mexfuncs.c
mex -I../../gdsio set_element_data.c ../../gdsio/mexfuncs.c
system('del *.o');

cd ../../../Structures/private
mex datamatrixmex.c
system('del *.o');

% Boolean functions
fprintf('\n\n>>>>>\n');
fprintf('>>>>>  Compiling Boolean set algebra functions (Clipper)...\n');
fprintf('>>>>>\n\n');

% for Clipper library
cd ../../Boolean
mex poly_boolmex.cpp clipper.cpp
system('del *.o');

% back up
cd ..

