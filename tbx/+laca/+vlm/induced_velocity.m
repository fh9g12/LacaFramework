function V = induced_velocity(point,panels,ringNodes,teRings,teNodes,te_idx,gamma,XZ_sym)
%GENERATE_AIC Summary of this function goes here
%   Detailed explanation goes here

N = size(panels,2);
V = zeros(size(point));
for j = 1:N
    coords = ringNodes(:,panels(:,j));
    if XZ_sym
        sym_coords = [1 0 0;0 -1 0;0 0 1]*coords;
        for i = 1:size(V,2)
            V(:,j) = V(:,j) + laca.vlm.vortex_ring(coords,point(:,i),gamma(j));
            V(:,j) = V(:,j) + laca.vlm.vortex_ring(sym_coords,point(:,i),-gamma(j));
        end
    else
        for i = 1:size(V,2)
            V(:,j) = V(:,j) + laca.vlm.vortex_ring(coords,point(:,i),gamma(j));
        end
    end
end

%compute influence of wake panels
for i = 1:size(te_idx,1)
    idx = te_idx(i,2);
    coords = teNodes(:,teRings(:,i));
    if XZ_sym
        sym_coords = [1 0 0;0 -1 0;0 0 1]*coords;
        for j = 1:1:size(V,2)   
            V(:,j) = V(:,j) + laca.vlm.horseshoe(coords,point(:,j),gamma(idx));
            V(:,j) = V(:,j) + laca.vlm.horseshoe(sym_coords,point(:,j),-gamma(idx));
        end
    else
        for j = 1:1:size(V,2)   
            V(:,j) = V(:,j) + laca.vlm.horseshoe(coords,point(:,j),gamma(idx));
        end
    end
end
end

