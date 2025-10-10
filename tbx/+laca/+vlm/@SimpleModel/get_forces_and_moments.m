function res = get_forces_and_moments(obj,p)
%get_forces_and_moments get forces and moments about point p
res = zeros(6,1);
for i = 1:length(obj.Wings)
    res = res + obj.Wings{i}.get_forces_and_moments(p,false);
end
end
