function out = panel_normal(panels,nodes)
    %get the four cardinal points of the box 
    A = nodes(:,panels(1,:));
    B = nodes(:,panels(2,:));
    C = nodes(:,panels(3,:));
    D = nodes(:,panels(4,:));
    
    % Calculate vectors CA and BD
    CA_x = C(1,:) - A(1,:);
    CA_y = C(2,:) - A(2,:);
    CA_z = C(3,:) - A(3,:);
    BD_x = B(1,:) - D(1,:);
    BD_y = B(2,:) - D(2,:);
    BD_z = B(3,:) - D(3,:);
    
    % Cross product CA × BD explicitly
    cross_x = CA_y.*BD_z - CA_z.*BD_y;
    cross_y = CA_z.*BD_x - CA_x.*BD_z;
    cross_z = CA_x.*BD_y - CA_y.*BD_x;
    
    % Normalize
    norm_val = sqrt(cross_x.^2 + cross_y.^2 + cross_z.^2);
    out = [cross_x./norm_val; cross_y./norm_val; cross_z./norm_val];
end

