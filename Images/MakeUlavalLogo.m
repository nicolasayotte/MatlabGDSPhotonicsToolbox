
close all; clear all; clc;

pm = imread('profilentrepreneurial_logo.png');
bm=zeros(size(pm));
bm(find(pm>126)) = 0;
bm(find(pm<=126)) = 1;

pixel.width  = 0.3;
pixel.height = 0.3;
bs = gdsii_bitmap(bm, pixel, 'ULAVAL_LOGO', 100);

L = gds_library('LOGO.DB', 'uunit',1e-6, 'dbunit',1e-9, bs);
write_gds_library(L, '!logo_ulaval.gds');


pm = imread('logoCOPL_BW.png');
bm=zeros(size(pm));
bm(find(pm>126)) = 0;
bm(find(pm<=126)) = 1;

pixel.width  = 0.3;
pixel.height = 0.3;
bs = gdsii_bitmap(bm, pixel, 'COPL_LOGO', 100);

L = gds_library('LOGO.DB', 'uunit',1e-6, 'dbunit',1e-9, bs);
write_gds_library(L, '!logo_copl.gds');
