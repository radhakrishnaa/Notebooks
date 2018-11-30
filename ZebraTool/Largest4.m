function [ Lr ] = Largest4( x,y,z,k )
% Find the largest number between 4 elements and return back the largest
% index 0,1,2,3 in case the other three elements are smaller than 8
% otherwise return 4
T=8;temp=0;
if x>=y && x>=z && x>=k 
   if y<T && z<T && k<T
   Lr=0;temp=1;
   end
end

if y>=x && y>=z && x>=k 
   if x<T && z<T && k<T
   Lr=1;temp=1;
   end
end

if z>=x && z>=y && z>=k 
if x<T && y<T && k<T
   Lr=2;temp=1;
end
end

if k>=x && k>=y && k>=z
if x<T && y<T && z<T
   Lr=3;temp=1;
end
end

if temp==0
   Lr=4;
end

end

