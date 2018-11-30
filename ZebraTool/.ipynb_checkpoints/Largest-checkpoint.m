function [ Lr ] = largest( x,y,z )
% Find the largest number between 3 elements and return back the largest
% index 0,1,2
if x>=y && x>=z
   Lr=0;
end

if y>=x && y>=z
   Lr=1;
end

if z>=x && z>=y
   Lr=2;
end

end

