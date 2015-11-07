%% Compiling the mex files
cd 'Functions';
cd 'Utils';
mex -O CornersToRects.c;
mex -O RotTransXYCell.c;
cd ..

cd 'GDSII Library';
makemex;
cd ..
cd ..