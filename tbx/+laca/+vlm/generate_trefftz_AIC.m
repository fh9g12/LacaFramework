function AIC = generate_trefftz_AIC(panels,ringNodes,collocation,teRings,teNodes,te_idx,XZ_sym)
%GENERATE_TREFFTZ_AIC Generate AIC matrix using Trefftz plane method
%   Uses infinite vortex lines extending downstream to infinity
%   This is appropriate for induced drag calculations in the far field
normal = laca.vlm.panel_normal(panels,ringNodes);
N = size(panels,2);
AIC = zeros(N);

% Only compute influence of wake panels using infinite vortex lines
% (bound vortices don't contribute in Trefftz plane analysis)
for i = 1:size(te_idx,1)
    idx = te_idx(i,2);
    
    % Get wake vortex positions - teRings goes: LE_left, LE_right, TE_right, TE_left
    % Use trailing edge filaments: 2->3 (LE_right to TE_right) and 1->4 (LE_left to TE_left)
    
    % Calculate wake vortex line endpoints once per wake panel
    p1 = teNodes(:,teRings(1,i)); % LE_left
    p2 = teNodes(:,teRings(2,i)); % LE_right
    p3 = teNodes(:,teRings(3,i)); % TE_right
    p4 = teNodes(:,teRings(4,i)); % TE_left
    
    for j = 1:N    
        % Use infinite vortex lines extending in x-direction (downstream)
        % Two infinite lines to represent the wake filaments
        
        % First infinite vortex line (2->3: LE_right to TE_right)
        v1 = laca.vlm.infinite_vortex_line(p2, p3, collocation(:,j), 1);
        
        % Second infinite vortex line (1->4: LE_left to TE_left)
        v2 = laca.vlm.infinite_vortex_line(p1, p4, collocation(:,j), 1);
        
        v = v1 + v2;
        
        if XZ_sym
            col = [collocation(1,j);-collocation(2,j);collocation(3,j)];
            
            % Apply symmetry to infinite vortex lines
            v1_sym = laca.vlm.infinite_vortex_line(p2, p3, col, 1);
            v2_sym = laca.vlm.infinite_vortex_line(p1, p4, col, 1);
            v_sym = v1_sym + v2_sym;
            
            v = v + [v_sym(1);-v_sym(2);v_sym(3)];
        end
        AIC(j,idx) = AIC(j,idx) + (v(1)*normal(1,j) + v(2)*normal(2,j) + v(3)*normal(3,j));
    end
end
end