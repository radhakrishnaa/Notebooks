function  FGmask=classify(BGmodel,im,param)
comp=abs(BGmodel.m-im);

FGmask=zeros(size(im,1),size(im,2));

FGmask(comp(:,:)> (sqrt( BGmodel.seg(:,:))*param.Tm))=1;

end
