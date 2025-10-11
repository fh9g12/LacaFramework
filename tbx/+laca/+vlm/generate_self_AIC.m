function AIC = generate_self_AIC(panels,ringNodes,collocation)
%GENERATE_AIC Summary of this function goes here
%   Detailed explanation goes here
normal = laca.vlm.panel_normal(panels,ringNodes);
N = size(panels,2);
AIC = zeros(N);
for i = 1:N
    coords = ringNodes(:,panels(:,i));
    % v = laca.vlm.vortex_line(coords(:,1),coords(:,2),collocation(:,j),1);
    v = laca.vlm.vortex_ring(coords,collocation(:,i),1);
    AIC(i,i) = v(1)*normal(1,i) + v(2)*normal(2,i) + v(3)*normal(3,i);
end
end

