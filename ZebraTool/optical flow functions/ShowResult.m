% show the result

%% ------Files & Folders---------------------------------------------------
% addpath(genpath('utils'));
% inputpath='.\Results\9\UV\Jaw_5';
% outputpath1='.\Results\9\Color_UV\Jaw_5';
% outputpath2='.\Results\Dirc_UV';

function ShowResult(inputpath) 
addpath(genpath('utils'));
outputpath1=strcat(inputpath(1:end-7),'Visualization\');

if (~isdir(outputpath1))
 mkdir(outputpath1);
end
% if (~isdir(outputpath2))
%  mkdir(outputpath2);
% end

  flist=dir(fullfile(inputpath,'*.mat'));
n=length(flist);

for i=1:n
    
     filn1=fullfile(inputpath,flist(i).name);
%       img1=(imread(fullfile(inputpath,flist(i).name)));

cc= (load(filn1));

% Display estimated flow fields
 subplot(1,2,1);imshow(flowToColor(cc.uv)); title('Color Coding');
subplot(1,2,2); plotflow(cc.uv);   title('Vector Plot');

frameName=(flist(i).name);
frameName=frameName(1:end-3);
xx=strcat(frameName,'png');

% fname = fname(1:end-4);
% %  fname=strcat(fname,'.png');
fiOT2=strcat(outputpath1,xx);
saveas(gcf,fiOT2)

% fname=sprintf('%s%s',flist(i).name);
%   fname = fname(1:end-4);
%   fname=strcat(fname,'.png');
%  fname_wpath1=fullfile(outputpath1,fname);
% %    colorMx=flowToColor(uv); 
% %  imwrite(bw,fname_wpath);
%   saveas(gcf,fname_wpath1)
% % save(fname_wpath1,'uv')

end


% Show result
% cc=load('Image002.mat');
% figure,imshow(flowToColor(cc.uv),[]);
% figure,plotflow(cc.uv);
% 




