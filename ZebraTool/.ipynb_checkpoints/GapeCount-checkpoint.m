function GapeCount(Tiff_name,Tiff_filePath)

% add functions paths
addpath(genpath('optical flow functions'))
addpath(genpath('background subtraction functions'))
addpath(genpath('export_fig'))
addpath('output')

%% intilize paramenters and flags
Optical_show=0;
atomatic_crop=0;
visual_response=0;
% run Optical Flow

Optical_matFile=strcat('./output/',Tiff_name,'/output_optical_flow/');
if (~isdir(Optical_matFile))
    mkdir(Optical_matFile);
end

% flist=dir(fullfile(inputpath_raw,'*.tif'));
% for i=1:size(flist,1)

%         fileName = fullfile(inputpath_raw,flist(i).name);
fileName=Tiff_filePath;
        tiffInfo = imfinfo(fileName);  %# Get the TIFF file information
        no_frame = numel(tiffInfo);    %# Get the number of images in the file
        Movie = cell(no_frame,1);      %# Preallocate the cell array
        
        for iFrame = 1:no_frame
            Movie{iFrame} = double(imread(fileName,'Index',iFrame,'Info',tiffInfo));
        end
        % % figure,imshow(fish)
        fish=Movie{1};

%%-------- Either interactive cropping or automatic cropping
if atomatic_crop==0
          figure,imshow(fish,[]);
          rect= getrect;
          Template=fish(rect(2):(rect(2)+rect(4)),rect(1):(rect(1)+rect(3)));
          
else % automatic jaw detetion
    load('raw_im.mat')
    Template=raw_im;
        c = normxcorr2(Template,fish);
        [ypeak, xpeak] = find(c==max(c(:)));
        yoffSet = ypeak-size(Template,1);
        xoffSet = xpeak-size(Template,2);
        hFig = figure;
        hAx  = axes;
        imshow(fish,'Parent', hAx);
        imrect(hAx, [xoffSet+1, yoffSet+1, size(Template,2), size(Template,1)]);
end
%---- loop to generate optical flow 
Folder1=strcat(Optical_matFile,'MatFile/');
             if (~isdir(Folder1))
                 mkdir(Folder1);
             end
        for iFrame = 1:no_frame-1
           
        im1=double(imread(fileName,'Index',iFrame,'Info',tiffInfo));
        im2=double(imread(fileName,'Index',iFrame+1,'Info',tiffInfo));
          
        if atomatic_crop==1
        myimg1 = imcrop(im1,[xoffSet+1, yoffSet+1, size(Template,2), size(Template,1)]);
        myimg2 = imcrop(im2,[xoffSet+1, yoffSet+1, size(Template,2), size(Template,1)]);
        else
        myimg1 = imcrop(im1,[rect(1), rect(2), size(Template,2), size(Template,1)]);
        myimg2 = imcrop(im2,[rect(1), rect(2), size(Template,2), size(Template,1)]);
        end
        
        uv = estimate_flow_interface( myimg1,  myimg2);
        out_pth=strcat(fullfile(Folder1,strcat('UV_',num2str(iFrame+1 ,'%03d'))),'.mat');
          
        save(out_pth,'uv');
 %      figure,imshow(myimg,[])
        end
        
%------- store UV 
        if Optical_show==1
%           UVPath='UV_Vec';
            ShowResult(Folder1)
        end

%  end
%%---------- End optical flow

%%-------------------------------------------------------
%%---------- Background subtraction begin
param.alpha=0.01;
param.Tm=2.2;

BG_outputpath=strcat('./output/',Tiff_name,'/output_Background_model/');
if (~isdir(BG_outputpath))
 mkdir(BG_outputpath);
end
            
option=3;
if option==3
    for i=1:30
    img=(imread(fileName,'Index',iFrame,'Info',tiffInfo));
    %img = uint8(img / 256);
    im(:,:,i)=double(img(:,:,1));
    end
else
    im=imread(fileName,'Index',iFrame,'Info',tiffInfo);
    %im = uint8(im / 256);
    im=double(im(:,:,1));

end

%- Initialize the model
 [BGmodel]=init_model(im,option );
%% -----Main Loop----------------------------------------------------------
for fr=1: no_frame

im=((imread(fileName,'Index',fr,'Info',tiffInfo)));
%im = uint8(im / 256);
im=double(im(:,:,1));

 %- Given model and new frame detect foreground
 FGmask=classify(BGmodel,im,param);

 %- Update the model with new frame 
 BGmodel=update_model(BGmodel,im,param);

 %- Save results

 filn=strcat(fullfile(BG_outputpath,strcat('BG_',num2str(fr,'%03d'))),'.png');
 imwrite(FGmask,filn);

end

%%---------------- cropping Background subtraction begin

inputpath_BK=BG_outputpath;
Crooped_BK_path=strcat('./output/',Tiff_name,'/output_Cropped_BK/');

if (~isdir(Crooped_BK_path))
    mkdir(Crooped_BK_path);
end

flist_BK=dir(fullfile(inputpath_BK,'*.png'));

for i=1:size(flist_BK,1)
im=imread(fullfile(inputpath_BK,flist_BK(i).name));
if atomatic_crop==1
myimg = imcrop(im,[xoffSet+1, yoffSet+1, size(Template,2), size(Template,1)]);
else
    myimg = imcrop(im,[rect(1), rect(2), size(Template,2), size(Template,1)]);
end
% figure,imshow(myimg,[])
ex=strcat('Image_',num2str(i,'%03d'),'.png');
imwrite(myimg,[Crooped_BK_path,'/', ex ]);
end
% % % %%---------- Background subtraction end

%%---------- Zebra jaw detection begin
%addpath('GT')
inputpath_UV=Folder1; 
inputpath_background_model=Crooped_BK_path;

flist=dir(fullfile(inputpath_UV,'*.mat'));
flist_BM=dir(fullfile(inputpath_background_model,'*.png'));
eps=0.0001;
n=length(flist);
p=0;

for i=1:n
im=load(fullfile(inputpath_UV,flist(i).name));
BM=imread(fullfile(inputpath_background_model,flist_BM(i+1).name));

U=im.uv(:,:,1);
V=im.uv(:,:,2);

%%%%%%%%%
vectormap=zeros(size(BM,1),size(BM,2));


U(U>0 & U<1)=0;
U(U<0 & U>-1)=0;

V(V>0 & V<1)=0;
V(V<0 & V>-1)=0;

vectormap(U>0 & V>0)=1;
vectormap(U>0 & V<0)=2;
vectormap(U<0 & V>0)=3;
vectormap(U<0 & V<0)=4;
% U(U>0)=0;V(V>0)=0;
% temp=U.*V;

Mag=sqrt(U.^2+V.^2);
Mag(vectormap~=3)=0;

BM = bwareaopen(BM,100);

myimg=Mag.*logical(BM);

%%----------- Visualization of the response
if visual_response==1
image_path_for_writing=strcat('./output/',Tiff_name,'/response_visualization/');
if (~isdir(image_path_for_writing))
    mkdir(image_path_for_writing);
end
% path=strcat(image_path_for_writing,'\myimg',Tiff_name,'.png');
%export_fig path -transparent -native;
%saveas(fig,path);

%save('C:\Users\yasminmq\Desktop\Zebrafish_summer\zebra2\res_visualization\myimg.mat','myimg');
image_name_to_write=strcat(image_path_for_writing,flist(i).name(1:end-4),'.png');

In=myimg;
mi=min(In(:));
ma=max(In(:));
In=255*(In-mi)/(ma-mi);

rgbImage = ind2rgb(uint8(In), jet(256));
imwrite(rgbImage,image_name_to_write);
end
close all;
%%-----------------------------------------

% myimg(myimg>20)=20;
% myimg(myimg<-20)=-20;
% myimg=myimg.*logical(BM);

xvalues1 = -20:20;
values=find(myimg~=0);
myimgnozero=myimg(values);
histimg=hist(myimgnozero(:),xvalues1);
histimg=histimg./sum(histimg(:));
strength=histimg(histimg~=0);
idx1 = isnan(histimg); 

%figure,bar(histimg);
if idx1==1
%train_hist(i-1,:)=0;
plot_jaw(i)=0;
else
 p=p+1;
 openjaw(p)=i;
 plot_jaw(i)=1*numel(strength);

%train_hist(i-1,:)=histimg;
end

end
close all;

plot_path=strcat('./output/',Tiff_name,'/Plots_Info/');
if (~isdir(plot_path))
    mkdir(plot_path);
end

figure('units','normalized','outerposition',[0 0 1 1],'visible','off')
stem(plot_jaw,'--go',...
    'LineWidth',2,...
    'MarkerSize',4,...
    'MarkerEdgeColor','b',...
    'MarkerFaceColor',[0.5,0.5,0.5])

%plot(plot_jaw,'r-o');
title('Zebra Fish Jaw Motion - Jaw')
ylabel('Mouth Openning Strength')
xlabel('Frame Number')
jawpath=strcat(plot_path,Tiff_name,'.png');
% export_fig jawpath -native;
 saveas(gca, jawpath, 'png');

 if atomatic_crop==1
myrect(1)=xoffSet+1;
myrect(2)=yoffSet+1;
myrect(3)=size(Template,2);
myrect(4)=size(Template,1);
else
    myrect(1)=rect(1);
myrect(2)=rect(2);
myrect(3)=size(Template,2);
myrect(4)=size(Template,1);
end
save(strcat(plot_path,'myrect.mat'),'myrect');
save(strcat(plot_path,'plot_jaw.mat'),'plot_jaw');

%------------------------------------
plot_jaw_filtered=Remove_frequent_responces( plot_jaw,n );
 
plot_jaw_filtered(plot_jaw_filtered<=2)=0;
openval=plot_jaw_filtered;

close all;
plot_jaw_filtered(plot_jaw_filtered == 0) = NaN;

figure('units','normalized','outerposition',[0 0 1 1],'visible','off')
stem(plot_jaw_filtered,'--go',...
    'LineWidth',2,...
    'MarkerSize',4,...
    'MarkerEdgeColor','b',...
    'MarkerFaceColor',[0.5,0.5,0.5])

title('Zebra Fish Jaw Motion filtered - Jaw')
ylabel('Mouth Openning Strength')
xlabel('Frame Number')
%jawpath=strcat(plot_path,'jaw_filtered.png');
jawpath=strcat(plot_path,Tiff_name,'_Filtered.png');
%export_fig jawpath  -native;
saveas(gca, jawpath, 'png');


save(strcat(plot_path,'plot_jaw_filtered.mat'),'plot_jaw_filtered');

[indices]=find(openval>0);
strength=openval(openval>0);

numel(openval(openval>0));

indices=reshape(indices,size(indices,2),size(indices,1));
strength=reshape(strength,size(strength,2),size(strength,1));

if size (indices)==0
 valw(:,1)=0;
valw(:,2)=0;
else
valw=zeros(size(indices,1),2);
valw(:,1)=indices;
valw(:,2)=strength;
end

filename = strcat(plot_path, Tiff_name,'.xlsx');
xlswrite(filename,valw);

end