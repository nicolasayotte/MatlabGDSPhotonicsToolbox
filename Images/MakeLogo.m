%% This little code will split an image into  R G B channels and binarize them into
% square pixels. Those pixels are then written into a gds file for reuse.
close all; clear all; clc;

pm = imread('GDSPhotonicLibrary_BW.jpg');

binarizationLevel = 126;  % byte value for black and white
pixelSize = 0.3;  % in microns
layer = 1;
dtype = 1;

% Binarization
bm=zeros(size(pm));
bm(pm > 126) = 0;
bm(pm <= 126) = 1;

pixel.width  = pixelSize;
pixel.height = pixelSize;
bs = gdsii_bitmap(bm, pixel, 'GDSPhotonicLibrary', layer, dtype);

L = gds_library('LOGO.DB', 'uunit', 1e-6, 'dbunit', 1e-9, bs);
write_gds_library(L, '!logo_GDSPhotonicLibrary.gds');
