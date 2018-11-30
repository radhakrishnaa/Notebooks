function BGmodel=update_model(BGmodel,im,param)

%Update the mean

frame_T=im*param.alpha;
frame_T_1=BGmodel.m*(1-param.alpha);

NewMean=frame_T+frame_T_1;

%------------ Update the Segma

frame_Tseg=((im-BGmodel.m).^2)*param.alpha;
frame_Tseg_1=(1-param.alpha)*BGmodel.seg;

NewSeg=frame_Tseg+frame_Tseg_1;


BGmodel.m=NewMean;
BGmodel.seg=NewSeg;

end

