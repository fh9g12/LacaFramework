function AIC = generate_AIC(panels,ringNodes,collocation,teRings,teNodes,te_idx,XZ_sym)
%GENERATE_AIC Summary of this function goes here
%   Detailed explanation goes here
normal = laca.vlm.panel_normal(panels,ringNodes);
N = size(panels,2);
AIC = zeros(N);
for j = 1:N
    if XZ_sym
        coords = ringNodes(:,panels(:,j));
        sym_coords = [1 0 0;0 -1 0;0 0 1]*coords;
        for i = 1:N
            v = laca.vlm.vortex_ring(coords,collocation(:,i),1);
            v = v + laca.vlm.vortex_ring(sym_coords,collocation(:,i),-1);
            AIC(i,j) = v(1)*normal(1,i) + v(2)*normal(2,i) + v(3)*normal(3,i);
        end
    else
        coords = ringNodes(:,panels(:,j));
        for i = 1:N
            v = laca.vlm.vortex_ring(coords,collocation(:,i),1);
            AIC(i,j) = v(1)*normal(1,i) + v(2)*normal(2,i) + v(3)*normal(3,i);
        end
    end
end

%compute influence of wake panels
for i = 1:size(te_idx,1)
    idx = te_idx(i,2);
    coords = teNodes(:,teRings(:,i));
    if XZ_sym
        sym_coords = [1 0 0;0 -1 0;0 0 1]*coords;
        for j = 1:N    
            v = laca.vlm.horseshoe(coords,collocation(:,j),1);
            v = v + laca.vlm.horseshoe(sym_coords,collocation(:,j),-1);
            AIC(j,idx) = AIC(j,idx) + (v(1)*normal(1,j) + v(2)*normal(2,j) + v(3)*normal(3,j));
        end
    else
        for j = 1:N    
            v = laca.vlm.horseshoe(coords,collocation(:,j),1);
            AIC(j,idx) = AIC(j,idx) + (v(1)*normal(1,j) + v(2)*normal(2,j) + v(3)*normal(3,j));
        end
    end 
end
end

