%% main program
 function GapeCounter_MU(baseName,folder)
 
%  Zebrafish gape counter is a tool to detect and analysis the jow movemetn
%  of zebrafish and count the number of jow oppenning
% for more details refer to the published paper

%  ”Dissecting Branchiomotor Neuron Circuits in ZebrafishToward High-Throughput Automated
% Analysis of Jaw Movements”.  IEEE International Symposium on Biomedical Imaging (ISBI’18),
% 2018.

%  or contact
% Yasmin M. Kassim @  ymkgz8@mail.missouri.edu
% Noor Al-Shakarji @ nmahyd@mail.missouri.edu
% Kannappan Palaniappan @  palaniappank@missouri.edu
 
close all
fileID = fopen('imageFile.txt','r');
folder = fgetl(fileID);
baseName = fgetl(fileID);
fclose(fileID)
addpath(folder)
% [baseName, folder] = uigetfile('*.tif');
filename = fullfile(folder, baseName);
GapeCount(baseName(1:end-4),filename);
 end