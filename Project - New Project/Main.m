%% Main
% Author : Nicolas Ayotte
% Creation date : 31/03/2014
% The entire programs is in microns.
clear all; close all; clear classes; clc; format long; format compact;

% ProjectDefinition.m is the reference for all your project informations


%% Make all

Cell_A_StraightWG;
Cell_B_Microrings;
Cell_C_CompactIBGs;
Cell_D_RidgeIBGs;
Cell_E_CustomIBGs;
Cell_F_MZI
Cell_RoutingWG;

%% Merge the cells into a master GDS
MergeCells;


%% Cast the ulaval map to a different layer map
% ExportMap;