function AIC = generate_self_AIC(panels,ringNodes,collocation)
%GENERATE_AIC Summary of this function goes here
%   Detailed explanation goes here
normal = laca.vlm.panel_normal(panels,ringNodes);
N = size(panels,2);
AIC = zeros(N);
for j = 1:N
    coords = ringNodes(:,panels(:,j));
    v = laca.vlm.vortex_line(coords(:,1),coords(:,2),collocation(:,j),1);
    AIC(j,j) = dot(v,normal(:,j));
end
end

