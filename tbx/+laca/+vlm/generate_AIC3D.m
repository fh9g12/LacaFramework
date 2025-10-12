function [AIC3D,AIC] = generate_AIC3D(panels,ringNodes,collocation,teRings,teNodes,te_idx,XZ_sym)
%GENERATE_AIC Summary of this function goes here
%   Detailed explanation goes here
normal = laca.vlm.panel_normal(panels,ringNodes);
M = size(collocation,2);
N = size(panels,2);
AIC3D = zeros(M,N,3);
for j = 1:N
    coords = ringNodes(:,panels(:,j));
    if XZ_sym
        sym_coords = [1 0 0;0 -1 0;0 0 1]*coords;
        for i = 1:M
            v = laca.vlm.vortex_ring(coords,collocation(:,i),1);
            v = v + laca.vlm.vortex_ring(sym_coords,collocation(:,i),-1);
            for k = 1:3
                AIC3D(i,j,k) = v(k);
            end
        end
    else
        for i = 1:M
            v = laca.vlm.vortex_ring(coords,collocation(:,i),1);
            for k = 1:3
                AIC3D(i,j,k) = v(k);
            end
        end
    end 
end

%compute influence of wake panels
for i = 1:size(te_idx,1)
    idx = te_idx(i,2);
    coords = teNodes(:,teRings(:,i));
    if XZ_sym
        sym_coords = [1 0 0;0 -1 0;0 0 1]*coords;
        for j = 1:M
            v = laca.vlm.horseshoe(coords,collocation(:,j),1);
            v = v + laca.vlm.horseshoe(sym_coords,collocation(:,j),-1);
            for k = 1:3
                AIC3D(j,idx,k) = AIC3D(j,idx,k) + v(k);
            end
        end
    else
        for j = 1:M
            v = laca.vlm.horseshoe(coords,collocation(:,j),1);
            for k = 1:3
                AIC3D(j,idx,k) = AIC3D(j,idx,k) + v(k);
            end
        end
    end
end
AIC = sum(AIC3D.*repmat(reshape(normal',1,[],3),M,1,1),3);
end

