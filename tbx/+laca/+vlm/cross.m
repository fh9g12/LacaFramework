function c = cross(a,b)
%CROSS Summary of this function goes here
%   Detailed explanation goes here
c = a*0;
c(3,:) = a(1,:).*b(2,:)-a(2,:).*b(1,:);
c(1,:) = a(2,:).*b(3,:)-a(3,:).*b(2,:);
c(2,:) = a(3,:).*b(1,:)-a(1,:).*b(3,:);
end