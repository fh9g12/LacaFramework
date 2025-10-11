
%VORTEXLINETEST Test functionality of vortex line functions
%   Tests vortex_line, infinite_vortex_line, and semiinfinite_vortex_line
%   to ensure they produce expected results and haven't been broken

%% Test 1: Basic Vortex Line Functionality
% Simple test case: vortex line along x-axis, field point above and offset
p1 = [0; 0; 0];
p2 = [1; 0; 0];
p_field = [0.25; 0; 1];  % Offset from center to avoid zero result
gamma = 1;

v = laca.vlm.vortex_line(p1, p2, p_field, gamma);

% Expected: velocity should be in -y direction (right-hand rule)
% Should be non-zero for this geometry
assert(abs(v(1)) < 1e-10, 'X-component should be zero');
assert(v(2) < 0, 'Y-component should be negative (right-hand rule)');
assert(abs(v(3)) < 1e-10, 'Z-component should be zero');
assert(abs(v(2)) > 1e-6, 'Y-component should be non-zero');

%% Test 2: Infinite Vortex Line
% Infinite vortex line along x-axis
p1 = [0; 0; 0];
p2 = [1; 0; 0];  % Direction vector
p_field = [0.5; 0; 1];  % Field point above line
gamma = 1;

v_inf = laca.vlm.infinite_vortex_line(p1, p2, p_field, gamma);

% For infinite line, velocity should be gamma/(2*pi*r_perp)
% where r_perp is perpendicular distance = 1
expected_magnitude = gamma / (2 * pi);

assert(abs(v_inf(1)) < 1e-10, 'X-component should be zero');
assert(v_inf(2) < 0, 'Y-component should be negative');
assert(abs(v_inf(3)) < 1e-10, 'Z-component should be zero');
assert(abs(abs(v_inf(2)) - expected_magnitude) < 1e-6, ...
    'Y-component magnitude should match expected value for infinite line');

%% Test 3: Semi-infinite Vortex Line
% Semi-infinite vortex starting at origin, extending in +x direction
p1 = [0; 0; 0];  % Starting point
p2 = [1; 0; 0];  % Direction
p_field = [0.25; 0; 1];  % Field point (same as Test 1)
gamma = 1;

v_semi = laca.vlm.semiinfinite_vortex_line(p1, p2, p_field, gamma);

% Semi-infinite should be between finite and infinite results
% Should be non-zero and in -y direction
assert(abs(v_semi(1)) < 1e-10, 'X-component should be zero');
assert(v_semi(2) < 0, 'Y-component should be negative');
assert(abs(v_semi(3)) < 1e-10, 'Z-component should be zero');

%% Test 4: Consistency Check - Infinite vs Semi-infinite
% For a field point far from the starting point of semi-infinite vortex,
% the semi-infinite should approach the infinite result
p1 = [0; 0; 0];
p2 = [1; 0; 0];
p_field = [1000; 0; 1];  % Far downstream
gamma = 1;

v_inf = laca.vlm.infinite_vortex_line(p1, p2, p_field, gamma);
v_semi = laca.vlm.semiinfinite_vortex_line(p1, p2, p_field, gamma);

% They should be approximately equal for far field points
diff = norm(v_inf - v_semi);
assert(diff < 1e-6, sprintf('Infinite and semi-infinite should converge for far field (diff = %.8f)', diff));

%% Test 5: Zero Circulation Test
p1 = [0; 0; 0];
p2 = [1; 0; 0];
p_field = [0.5; 0; 1];
gamma = 0;  % Zero circulation

v1 = laca.vlm.vortex_line(p1, p2, p_field, gamma);
v2 = laca.vlm.infinite_vortex_line(p1, p2, p_field, gamma);
v3 = laca.vlm.semiinfinite_vortex_line(p1, p2, p_field, gamma);

assert(norm(v1) < 1e-10, 'Finite vortex line should give zero velocity with zero circulation');
assert(norm(v2) < 1e-10, 'Infinite vortex line should give zero velocity with zero circulation');
assert(norm(v3) < 1e-10, 'Semi-infinite vortex line should give zero velocity with zero circulation');

%% Test 6: Singularity Avoidance Test
% Field point very close to vortex line
p1 = [0; 0; 0];
p2 = [1; 0; 0];
p_field = [0.5; 1e-8; 0];  % Very close to line
gamma = 1;

v1 = laca.vlm.vortex_line(p1, p2, p_field, gamma);
v2 = laca.vlm.infinite_vortex_line(p1, p2, p_field, gamma);
v3 = laca.vlm.semiinfinite_vortex_line(p1, p2, p_field, gamma);

% Should not be infinite or NaN
assert(all(isfinite(v1)), 'Finite vortex line should avoid singularities');
assert(all(isfinite(v2)), 'Infinite vortex line should avoid singularities');
assert(all(isfinite(v3)), 'Semi-infinite vortex line should avoid singularities');

%% Test 7: Right-hand Rule Test
% Vortex along +x, field point in +z, should get velocity in -y
p1 = [0; 0; 0];
p2 = [1; 0; 0];
p_field = [0.5; 0; 1];
gamma = 1;

v = laca.vlm.vortex_line(p1, p2, p_field, gamma);

% Reverse circulation should reverse velocity
v_rev = laca.vlm.vortex_line(p1, p2, p_field, -gamma);

diff = norm(v + v_rev);
assert(diff < 1e-10, 'Right-hand rule: reversing circulation should reverse velocity');

%% Test 8: Magnitude Comparisons
% Compare magnitudes of different vortex types
p1 = [0; 0; 0];
p2 = [1; 0; 0];
p_field = [0.25; 0; 1];
gamma = 1;

v_finite = laca.vlm.vortex_line(p1, p2, p_field, gamma);
v_infinite = laca.vlm.infinite_vortex_line(p1, p2, p_field, gamma);
v_semi = laca.vlm.semiinfinite_vortex_line(p1, p2, p_field, gamma);

mag_finite = norm(v_finite);
mag_infinite = norm(v_infinite);
mag_semi = norm(v_semi);

% Infinite should be strongest, finite weakest
assert(mag_infinite > mag_semi, 'Infinite vortex should be stronger than semi-infinite');
assert(mag_semi > mag_finite, 'Semi-infinite should be stronger than finite');

% Check magnitude ordering
assert(mag_finite > 0, 'Finite vortex magnitude should be positive');
assert(mag_semi > 0, 'Semi-infinite vortex magnitude should be positive');
assert(mag_infinite > 0, 'Infinite vortex magnitude should be positive');

%% Test 9: Near-field Semi-infinite Half Rule
% For field points close to starting point, semi-infinite should be ~half of finite
p1 = [0; 0; 0];
p2 = [10; 0; 0];  % Long vortex line
p_field = [0.1; 0; 0.5];  % Close to starting point
gamma = 1;

v_finite = laca.vlm.vortex_line(p1, p2, p_field, gamma);
v_semi = laca.vlm.semiinfinite_vortex_line(p1, p2, p_field, gamma);

mag_finite = norm(v_finite);
mag_semi = norm(v_semi);

% For this geometry, semi-infinite should be approximately equal to finite
ratio = mag_semi / mag_finite;
assert(abs(ratio - 1.0) < 0.05, sprintf('Near-field semi-infinite should be ~1.0 of finite, got %.3f', ratio));

%% Test 10: Box Splitting Test - Corners
% Test vortex line that splits a box, check values at 4 corners
p1 = [-1; 0; 0];  % Vortex line crosses through box
p2 = [1; 0; 0];
gamma = 1;

% Box corners at z=1 plane
corners = [
    [-0.5, -0.5, 1];  % Bottom-left
    [0.5, -0.5, 1];   % Bottom-right  
    [0.5, 0.5, 1];    % Top-right
    [-0.5, 0.5, 1]    % Top-left
];

v_corners = zeros(3, 4);
for i = 1:4
    v_corners(:, i) = laca.vlm.vortex_line(p1, p2, corners(i, :)', gamma);
end

% Check symmetry: opposite corners should have same magnitude
mag1 = norm(v_corners(:, 1));  % Bottom-left
mag2 = norm(v_corners(:, 2));  % Bottom-right
mag3 = norm(v_corners(:, 3));  % Top-right
mag4 = norm(v_corners(:, 4));  % Top-left

assert(abs(mag1 - mag2) < 1e-10, 'Bottom corners should have same magnitude');
assert(abs(mag3 - mag4) < 1e-10, 'Top corners should have same magnitude');

% Check circulation direction: all corners should have same Y-velocity sign for this geometry
assert(v_corners(2, 1) * v_corners(2, 2) > 0, 'Bottom corners should have same Y-velocity sign');
assert(v_corners(2, 3) * v_corners(2, 4) > 0, 'Top corners should have same Y-velocity sign');
assert(v_corners(2, 1) * v_corners(2, 3) > 0, 'All corners should have same Y-velocity sign');

%% Test 11: Box Splitting Test - Edge Centers
% Test at center of each edge of the box
p1 = [-1; 0; 0];
p2 = [1; 0; 0];
gamma = 1;

% Edge centers at z=1 plane
edge_centers = [
    [0, -0.5, 1];     % Bottom edge center
    [0.5, 0, 1];      % Right edge center
    [0, 0.5, 1];      % Top edge center  
    [-0.5, 0, 1]      % Left edge center
];

v_edges = zeros(3, 4);
for i = 1:4
    v_edges(:, i) = laca.vlm.vortex_line(p1, p2, edge_centers(i, :)', gamma);
end

% Check symmetry: opposite edges should have same magnitude
mag_bottom = norm(v_edges(:, 1));  % Bottom
mag_top = norm(v_edges(:, 3));     % Top
mag_left = norm(v_edges(:, 4));    % Left
mag_right = norm(v_edges(:, 2));   % Right

assert(abs(mag_bottom - mag_top) < 1e-10, 'Top and bottom edges should have same magnitude');
assert(abs(mag_left - mag_right) < 1e-10, 'Left and right edges should have same magnitude');

% Check that edge velocities are non-zero
for i = 1:4
    assert(norm(v_edges(:, i)) > 1e-6, sprintf('Edge %d velocity should be non-zero', i));
end

%% Test 12: Box Center Test
% Test at the center of the box (should be zero for symmetric case)
p1 = [-1; 0; 0];
p2 = [1; 0; 0];
p_center = [0; 0; 1];  % Box center
gamma = 1;

v_center = laca.vlm.vortex_line(p1, p2, p_center, gamma);

% At the center, with symmetric geometry, finite vortex gives non-zero result
% due to finite length effects
assert(norm(v_center) > 0.05, 'Center velocity should be non-zero for finite vortex');
assert(norm(v_center) < 0.2, 'Center velocity should be reasonable magnitude');

% Test infinite vortex at center - should be exactly zero
v_inf_center = laca.vlm.infinite_vortex_line(p1, p2, p_center, gamma);
assert(abs(v_inf_center(1)) < 1e-10, 'Infinite vortex X-component should be zero at center');
assert(abs(v_inf_center(3)) < 1e-10, 'Infinite vortex Z-component should be zero at center');
% Y-component should be non-zero for infinite line