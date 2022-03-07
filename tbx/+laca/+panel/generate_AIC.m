function AIC = generate_AIC(rings,collocation,normal,te_rings,te_idx)
%GENERATE_AIC Summary of this function goes here
%   Detailed explanation goes here
N = size(rings,3);
AIC = zeros(N);
for j = 1:N
    coords = rings(:,:,j)';
    for i = 1:N
        v = laca.panel.vortex_ring(coords,collocation(:,i),1);
        AIC(i,j) = dot(v,normal(:,i));
    end
end

%compute influence of wake panels
for i = 1:size(te_idx,1)
    idx = te_idx(i,2);
    coords = te_rings(:,:,i)';
    for j = 1:N    
        v = laca.panel.vortex_ring(coords,collocation(:,j),1);
        AIC(j,idx) = AIC(j,idx) + dot(v,normal(:,j));
    end
end
end
