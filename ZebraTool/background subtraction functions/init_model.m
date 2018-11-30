function [BGmodel]=init_model(im,option)


% case 1 set to zero
switch option
    case 1
        mean_Pix=zeros(size(im,1),size(im,2));
        seg_Pix=zeros(size(im,1),size(im,2));
        
%case2 set to the first frame
    case 2
        
        mean_Pix(:,:)=im;
        seg_Pix(:,:)= 100;
        
% case3 set to 100 frames
    case 3
        for i=1:size(im,1)
            for j=1:size(im,2)
                mean_Pix(i,j,:)= mean(im(i,j,:));
                seg_Pix(:,:)= 100;
            end
        end
        
end

BGmodel.m=mean_Pix;
BGmodel.seg=seg_Pix;

end

