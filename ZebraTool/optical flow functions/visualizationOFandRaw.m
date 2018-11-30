
path1=('E:\ZebraFish\Code\1\Tool\xx\4\MVisualization');
path2=('D:\COMPUTER SCIENCE LEC\Dr. Pal\zebra fish\Movei\9\4.tif');
outputpath=('E:\ZebraFish\Code\1\Tool\xx\4\combinations\');
if (~isdir(outputpath))
    mkdir(outputpath);
end
 tiffInfo = imfinfo(path2);  %# Get the TIFF file information
        no_frame = numel(tiffInfo);    %# Get the number of images in the file
        Movie = cell(no_frame,1);      %# Preallocate the cell array
        
        for iFrame = 1:no_frame
            Movie{iFrame} = double(imread(path2,'Index',iFrame,'Info',tiffInfo));
        end
        
        flist=dir(fullfile(path1,'*.png'));
        f = figure('visible','off');
        for i=2:no_frame         
        subplot(2,1,1),imshow(Movie{i},[])
       subplot(2,1,2),imshow(imread(strcat(path1,'\',flist(i-1).name)));
       saveas(f,strcat(outputpath,num2str(i),'.png'))
        end