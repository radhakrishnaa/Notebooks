% flow_main noor
% im1=imread('D:\COMPUTER SCIENCE LEC\Dr. Pal\zebra fish\ZebraFishFrame\Image001.jpg');
% im2=imread('D:\COMPUTER SCIENCE LEC\Dr. Pal\zebra fish\ZebraFishFrame\Image050.jpg');



%% ------Files & Folders---------------------------------------------------

function Optical_flow_main(inputpath)
clc
% inputpath='.\MovieFrame'; % run videoConverter.m code to get Movie Frame folder
outputpath1='UV_Vec'; 
% outputpath2='.\Results\Dirc_Results';
if (~isdir(outputpath1))  
 mkdir(outputpath1);
end
flist=dir(fullfile(inputpath,'*.jpg'));
% flist=dir(fullfile(inputpath,'*.mat'));
% for Mov=4:size(flist_mov,1); % four is correct dont change it 
%  flist=dir( (fullfile(inputpath,flist_mov(Mov).name)));
 n=length(flist);
% img1= (imread(fullfile(inputpath,flist(1).name)));
for i=2:n
     img1=(imread(fullfile(inputpath,flist(i).name)));
     img2=(imread(fullfile(inputpath,flist(i-1).name)));
     
% img2= (imread(fullfile(inputpath,flist(i).name)));
% img1= (imread(filn1));
% img2= (imread(filn2));

  uv = estimate_flow_interface(img1, img2);

% Display estimated flow fields
% figure; subplot(1,2,1);imshow(uint8(flowToColor(uv))); title('Middlebury color coding');
% subplot(1,2,2); plotflow(uv);   title('Vector plot');

%imshow(uint8(flowToColor(uv))); title('ZebraFish');
% xx=[1,2,3,4];
% fname=sprintf('%s%s',flist(i).name);
%   fname = fname(1:end-4);
% fiOT1=strcat('D:\COMPUTER SCIENCE LEC\Dr. Pal\zebra fish\Movei\5\Jaw_1\im',num2str(i-1),'_0_0','.jpg');
%      fiOT2=strcat(outputpath1,'\im',num2str(i),'_0_0','.mat');
           
 out_pth=strcat(fullfile(outputpath1, strcat('UV_',num2str(i ,'%03d'))),'.mat');
%  imwrite(FGmask,filn);
%   fname=strcat(fname,'.mat');
%  fname_wpath1=fullfile(fiOT2,fname);
%    colorMx=flowToColor(uv); 
%  imwrite(bw,fname_wpath);
% saveas(gcf,fname_wpath)
save(out_pth,'uv');
 
end
end
 
% Show result
% cc=load('Image002.mat');
% figure,imshow(flowToColor(cc.uv),[]);
% figure,plotflow(cc.uv);
% 
