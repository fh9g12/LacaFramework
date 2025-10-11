function out = panel_area(panels,nodes)
%get the four cardinal points of the box
A = nodes(:,panels(1,:));
B = nodes(:,panels(2,:));
C = nodes(:,panels(3,:));
D = nodes(:,panels(4,:));

% Calculate vectors for first triangle (B-A, D-A)
BA_x = B(1,:) - A(1,:);
BA_y = B(2,:) - A(2,:);
BA_z = B(3,:) - A(3,:);
DA_x = D(1,:) - A(1,:);
DA_y = D(2,:) - A(2,:);
DA_z = D(3,:) - A(3,:);

% Cross product (B-A) × (D-A) explicitly
cross1_x = BA_y.*DA_z - BA_z.*DA_y;
cross1_y = BA_z.*DA_x - BA_x.*DA_z;
cross1_z = BA_x.*DA_y - BA_y.*DA_x;

% Magnitude of first cross product
mag1 = sqrt(cross1_x.^2 + cross1_y.^2 + cross1_z.^2);

% Calculate vectors for second triangle (B-C, D-C)
BC_x = B(1,:) - C(1,:);
BC_y = B(2,:) - C(2,:);
BC_z = B(3,:) - C(3,:);
DC_x = D(1,:) - C(1,:);
DC_y = D(2,:) - C(2,:);
DC_z = D(3,:) - C(3,:);

% Cross product (B-C) × (D-C) explicitly
cross2_x = BC_y.*DC_z - BC_z.*DC_y;
cross2_y = BC_z.*DC_x - BC_x.*DC_z;
cross2_z = BC_x.*DC_y - BC_y.*DC_x;

% Magnitude of second cross product
mag2 = sqrt(cross2_x.^2 + cross2_y.^2 + cross2_z.^2);

% Calculate area as average of two triangles
out = 0.5*(mag1 + mag2)';
end

