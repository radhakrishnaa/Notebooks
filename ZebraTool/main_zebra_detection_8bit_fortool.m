clear all;

%%%%%%%%%%%%%% Reading Tiff file and Optical Flow 
%%---------- Begin Read Tiff
Optical_show=1;
atomatic_crop=0;

inputpath_raw='.\input\';
Optical_matFile='.\output\output_optical_flow\';

if (~isdir(Optical_matFile))
    mkdir(Optical_matFile);
end

flist=dir(fullfile(inputpath_raw,'*.tif'));
for i=1:size(flist,1)

        fileName = fullfile(inputpath_raw,flist(i).name);
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
else
    load('raw_im.mat')
    Template=raw_im;

end
        c = normxcorr2(Template,fish);
        [ypeak, xpeak] = find(c==max(c(:)));
        yoffSet = ypeak-size(Template,1);
        xoffSet = xpeak-size(Template,2);
        hFig = figure;
        hAx  = axes;
        imshow(fish,'Parent', hAx);
        imrect(hAx, [xoffSet+1, yoffSet+1, size(Template,2), size(Template,1)]);

%---- loop to generate optical flow 
        for iFrame = 1:no_frame-1
             
             %Create folder for save Optical flow
             Folder=strcat(fullfile(Optical_matFile, flist(i).name(1:end-4)));
             if (~isdir(Folder))
                 mkdir(Folder);
             end
             Folder1=strcat(Folder,'\MatFile\');
             if (~isdir(Folder1))
                 mkdir(Folder1);
             end
           
        im1=double(imread(fileName,'Index',iFrame,'Info',tiffInfo));
        im2=double(imread(fileName,'Index',iFrame+1,'Info',tiffInfo));
          
        myimg1 = imcrop(im1,[xoffSet+1, yoffSet+1, size(Template,2), size(Template,1)]);
        myimg2 = imcrop(im2,[xoffSet+1, yoffSet+1, size(Template,2), size(Template,1)]);
        
        uv = estimate_flow_interface( myimg1,  myimg2);
        out_pth=strcat(fullfile(Optical_matFile, flist(i).name(1:end-4),'MatFile',strcat('UV_',num2str(iFrame+1 ,'%03d'))),'.mat');
          
        save(out_pth,'uv');
 %      figure,imshow(myimg,[])
        end
%------- store UV 
        if Optical_show==1
%           UVPath='UV_Vec';
            ShowResult(Folder1)
        end

 end
%%---------- End optical flow

%%-------------------------------------------------------
%%---------- Background subtraction begin
param.alpha=0.01;
param.Tm=2.2;
inputpath='./input'; 
outputpath='./output/output_Background_model/';
if (~isdir(outputpath))
 mkdir(outputpath);
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
for fr=1:no_frame

im=((imread(fileName,'Index',fr,'Info',tiffInfo)));
%im = uint8(im / 256);
im=double(im(:,:,1));

 %- Given model and new frame detect foreground
 FGmask=classify(BGmodel,im,param);

 %- Update the model with new frame 
 BGmodel=update_model(BGmodel,im,param);

 %- Save results

 filn=strcat(fullfile(outputpath,strcat('BG_',num2str(fr,'%03d'))),'.png');
 imwrite(FGmask,filn);

end
%%---------------- cropping Background subtraction begin

inputpath_BK='.\output\output_Background_model\'; 
Crooped_BK_path='.\output\output_Cropped_BK\';

if (~isdir(Crooped_BK_path))
    mkdir(Crooped_BK_path);
end

flist_BK=dir(fullfile(inputpath_BK,'*.png'));

for i=1:size(flist_BK,1)
im=imread(fullfile(inputpath_BK,flist_BK(i).name));
myimg = imcrop(im,[xoffSet+1, yoffSet+1, size(Template,2), size(Template,1)]);
% figure,imshow(myimg,[])
ex=strcat('Image_',num2str(i,'%03d'),'.png');
imwrite(myimg,[Crooped_BK_path,'\', ex ]);
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
image_path_for_writing='C:\Users\yasminmq\Desktop\Zebrafish_summer\zebra2\res_visualization\img\';
%figure; 
%fig=imagesc(myimg);      
path=strcat('C:\Users\yasminmq\Desktop\Zebrafish_summer\zebra2\res_visualization\myimg',flist(i).name(1:end-4),'.png');
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

figure('units','normalized','outerposition',[0 0 1 1])
stem(plot_jaw,'--go',...
    'LineWidth',2,...
    'MarkerSize',4,...
    'MarkerEdgeColor','b',...
    'MarkerFaceColor',[0.5,0.5,0.5])

%plot(plot_jaw,'r-o');
title('Zebra Fish Jaw Motion - Jaw')
ylabel('Mouth Openning Strength')
xlabel('Frame Number')
export_fig 'jaw.png'  -native;

myrect(1)=xoffSet+1;
myrect(2)=yoffSet+1;
myrect(3)=size(Template,2);
myrect(4)=size(Template,1);
save('myrect.mat','myrect');
save('plot_jaw.mat','plot_jaw');

%------------------------------------
plot_jaw_filtered=Remove_frequent_responces( plot_jaw,n );
 
plot_jaw_filtered(plot_jaw_filtered<=2)=0;
openval=plot_jaw_filtered;

close all;
plot_jaw_filtered(plot_jaw_filtered == 0) = NaN;

figure('units','normalized','outerposition',[0 0 1 1])
stem(plot_jaw_filtered,'--go',...
    'LineWidth',2,...
    'MarkerSize',4,...
    'MarkerEdgeColor','b',...
    'MarkerFaceColor',[0.5,0.5,0.5])

title('Zebra Fish Jaw Motion filtered - Jaw')
ylabel('Mouth Openning Strength')
xlabel('Frame Number')
export_fig 'jaw_filtered.png'  -native;

myrect(1)=xoffSet+1;
myrect(2)=yoffSet+1;
myrect(3)=size(Template,2);
myrect(4)=size(Template,1);
save('plot_jaw_filtered.mat','plot_jaw_filtered'); 

[indices]=find(openval>0);
strength=openval(openval>0);

numel(openval(openval>0))

indices=reshape(indices,size(indices,2),size(indices,1));
strength=reshape(strength,size(strength,2),size(strength,1));

valw=zeros(size(indices,1),2);
valw(:,1)=indices;
valw(:,2)=strength;

filename = 'testdata2.xlsx';
xlswrite(filename,valw);
