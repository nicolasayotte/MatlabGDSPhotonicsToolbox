%% Main
% Author : Nicolas Ayotte
% Creation date : 31/03/2014
% The entire programs is in microns.
clear all; close all; clear classes; clc; format long; format compact;

% ProjectDefinition.m is the reference for all your project informations


%% Make all
CellA_StraightWG;
CellB_Microrings;
CellC_CompactIBGs;
CellD_RidgeIBGs;
CellE_CustomIBGs;
CellF_RoutingWG;


%% Merge the cells into a master GDS
MergeCells;


%% Cast the ulaval map to a different layer map
ExportMap;