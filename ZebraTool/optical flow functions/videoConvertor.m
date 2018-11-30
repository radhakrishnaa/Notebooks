clc; close all;
[imagelist,p]=uigetfile('*.tif','MultiSelect','on',...
     'Select LIST to plot'); pause(0.5); cd(p);
%  if ~iscell(imagelist); disp('imagelist not cell'); return; end;

t = Tiff(imagelist,'r');
imageData = read(t);
close(t)

% outputVideo = VideoWriter('0424_rat01.avi');
% outputVideo.FrameRate = 16;
% outputVideo.Quality = 100;
% open(outputVideo);
% 
% for i=1:numel(imagelist)
%     img=imread(imagelist(i));
%     writeVideo(outputVideo,img);
% end