%% Compiling the mex files

cd 'Functions - Utils'
mex -O CornersToRects.c;

cd ..

cd 'Functions - GDSII Library'
makemex
