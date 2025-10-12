function AIC = generate_trefftz_AIC(panels,ringNodes,teRings,teNodes,te_idx,XZ_sym)
%GENERATE_TREFFTZ_AIC Generate AIC matrix using Trefftz plane method
%   Uses infinite vortex lines extending downstream to infinity
%   This is appropriate for induced drag calculations in the far field
normal = laca.vlm.panel_normal(panels,ringNodes);
collocation = laca.vlm.panel_centroid(teRings,teNodes);

N = size(teRings,2);
AIC = zeros(N);

for i = 1:size(te_idx,1)
    coords = teNodes(:,teRings(:,i));
    if XZ_sym
        sym_coords = [1 0 0;0 -1 0;0 0 1]*coords;
        for j = 1:N  
            v = laca.vlm.infinite_vortex_line(coords(:,2), coords(:,3), collocation(:,j), 1);
            v = v + laca.vlm.infinite_vortex_line(coords(:,1), coords(:,4), collocation(:,j), -1);
            v = v + laca.vlm.infinite_vortex_line(sym_coords(:,2), sym_coords(:,3), collocation(:,j), -1);
            v = v + laca.vlm.infinite_vortex_line(sym_coords(:,1), sym_coords(:,4), collocation(:,j), 1);
            AIC(j,i) = (v(1)*normal(1,j) + v(2)*normal(2,j) + v(3)*normal(3,j));
        end
    else
        for j = 1:N  
            v = laca.vlm.infinite_vortex_line(coords(:,2), coords(:,3), collocation(:,j), 1);
            v = v + laca.vlm.infinite_vortex_line(coords(:,1), coords(:,4), collocation(:,j), -1);
            AIC(j,i) = (v(1)*normal(1,j) + v(2)*normal(2,j) + v(3)*normal(3,j));
        end
    end 
end
end