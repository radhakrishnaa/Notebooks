function [ plot_jaw_filtered ] = Remove_frequent_responces( plot_jaw,n )
plot_jaw_filtered=plot_jaw;
j=1;
for i=1:n 
    
    if j==n
        return
    else
    x=0;
    %%-------- Check whether it is 1,2,3, or 4 consective numbers
    if plot_jaw_filtered(j)>0 && plot_jaw_filtered(j+1)==0
        x=1;
    end
    if plot_jaw_filtered(j)>0 && plot_jaw_filtered(j+1)>0 && plot_jaw_filtered(j+2)==0
        x=2;
    end
    if plot_jaw_filtered(j)>0 && plot_jaw_filtered(j+1)>0 && plot_jaw_filtered(j+2)>0 && plot_jaw_filtered(j+3)==0
        x=3;
    end
    if plot_jaw_filtered(j)>0 && plot_jaw_filtered(j+1)>0 && plot_jaw_filtered(j+2)>0 && plot_jaw_filtered(j+3)>0
        x=4;    
    end
    %%-----------------------------------------------------------
    %%--- Now Check the consective numbers
    switch x
    
    case 2   %%--- if just two numbers, keep the largest
        if plot_jaw_filtered(j+1)>plot_jaw_filtered(j)
           plot_jaw_filtered(j)=0; j=j+1;
        else
           plot_jaw_filtered(j+1)=0; j=j+1; 
        end
    case 3   %%--- if just three numbers, keep the largest
        Lr=Largest(plot_jaw_filtered(j),plot_jaw_filtered(j+1),plot_jaw_filtered(j+2));
        switch Lr
            case 0
            plot_jaw_filtered(j+1)=0;plot_jaw_filtered(j+2)=0;
            case 1
            plot_jaw_filtered(j)=0;plot_jaw_filtered(j+2)=0;
            case 2
            plot_jaw_filtered(j+1)=0;plot_jaw_filtered(j)=0;
        end
        j=j+2;
    case 4   %%--- if  four numbers, keep the largest if the rest are smaller than T otherwise keep just two numbers
        Lr=Largest4(plot_jaw_filtered(j),plot_jaw_filtered(j+1),plot_jaw_filtered(j+2),plot_jaw_filtered(j+3));
        switch Lr
            case 0
                plot_jaw_filtered(j+1)=0;plot_jaw_filtered(j+2)=0;plot_jaw_filtered(j+3)=0;j=j+3;
            case 1
                plot_jaw_filtered(j)=0;plot_jaw_filtered(j+2)=0;plot_jaw_filtered(j+3)=0;j=j+3;
            case 2
                plot_jaw_filtered(j)=0;plot_jaw_filtered(j+1)=0;plot_jaw_filtered(j+3)=0;j=j+3;
            case 3
                plot_jaw_filtered(j)=0;plot_jaw_filtered(j+1)=0;plot_jaw_filtered(j+2)=0;j=j+3;
            case 4    %--- when there is more than one element >9
                if plot_jaw_filtered(j+1)>plot_jaw_filtered(j)
                plot_jaw_filtered(j)=0; j=j+1;
                else
                plot_jaw_filtered(j+1)=0; j=j+1;
                end               
         end
         end
          j=j+1;
    end

end
end

