function obj = generate_rings(obj)
%GENERATE_RINGS Summary of this function goes here
%   Detailed explanation goes here
for i= 1:length(obj.Wings)
    obj.Wings{i}.generate_rings();
end
end

