function AIC = generate_AIC(panels,ringNodes,collocation,teRings,teNodes,te_idx,XZ_sym)
%GENERATE_AIC Summary of this function goes here
%   Detailed explanation goes here
normal = laca.vlm.panel_normal(panels,ringNodes);
N = size(panels,2);
AIC = zeros(N);
for j = 1:N
    coords = ringNodes(:,panels(:,j));
    for i = 1:N
        v = laca.vlm.vortex_ring(coords,collocation(:,i),1);
        if XZ_sym
            col = [collocation(1,i);-collocation(2,i);collocation(3,i)];
            v_tmp = laca.vlm.vortex_ring(coords,col,1);
            v = v + [v_tmp(1);-v_tmp(2);v_tmp(3)];
        end
        AIC(i,j) = v(1)*normal(1,i) + v(2)*normal(2,i) + v(3)*normal(3,i);
    end
end

%compute influence of wake panels
for i = 1:size(te_idx,1)
    idx = te_idx(i,2);
    coords = teNodes(:,teRings(:,i));
    for j = 1:N    
        v = laca.vlm.horseshoe(coords,collocation(:,j),1);
        if XZ_sym
            col = [collocation(1,j);-collocation(2,j);collocation(3,j)];
            v_tmp = laca.vlm.horseshoe(coords,col,1);
            v = v + [v_tmp(1);-v_tmp(2);v_tmp(3)];
        end
        AIC(j,idx) = AIC(j,idx) + (v(1)*normal(1,j) + v(2)*normal(2,j) + v(3)*normal(3,j));
    end
end
end

