function AIC = generate_AIC(panels,ringNodes,collocation,teRings,teNodes,te_idx)
%GENERATE_AIC Summary of this function goes here
%   Detailed explanation goes here
normal = laca.vlm.panel_normal(panels,ringNodes);
N = size(panels,2);
AIC = zeros(N);
for j = 1:N
    coords = ringNodes(:,panels(:,j));
    for i = 1:N
        v = laca.vlm.vortex_ring(coords,collocation(:,i),1);
        AIC(i,j) = dot(v,normal(:,i));
    end
end

%compute influence of wake panels
for i = 1:size(te_idx,1)
    idx = te_idx(i,2);
    coords = teNodes(:,teRings(:,i));
    for j = 1:N    
        v = laca.vlm.horseshoe(coords,collocation(:,j),1);
        AIC(j,idx) = AIC(j,idx) + dot(v,normal(:,j));
    end
end
end

