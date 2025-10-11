function [q] = infinite_vortex_line(p1,p2,p_i,gamma,eta)
%INFINITE_VORTEX_LINE calculates the induced velocity at point p_i from an 
%infinite vortex line with direction (p2-p1) passing through points p1 and p2
%with strength gamma (right hand rule from p1 -> p2 direction)
%
% Inputs:
%   p1    - First point on the vortex line (3x1)
%   p2    - Second point on the vortex line (3x1) 
%   p_i   - Field point where velocity is calculated (3x1)
%   gamma - Vortex strength (scalar)
%   eta   - Cutoff distance to avoid singularities (optional, default 1e-6)
%
% Output:
%   q     - Induced velocity vector at p_i (3x1)

if nargin < 5
    eta = 1e-6;
end

% Get vortex line direction vector
dir_x = p2(1) - p1(1);
dir_y = p2(2) - p1(2);
dir_z = p2(3) - p1(3);
dir_mag = sqrt(dir_x^2 + dir_y^2 + dir_z^2);
dir_x = dir_x / dir_mag; % Normalize
dir_y = dir_y / dir_mag;
dir_z = dir_z / dir_mag;

% Vector from p1 to field point
r_x = p_i(1) - p1(1);
r_y = p_i(2) - p1(2);
r_z = p_i(3) - p1(3);

% Get perpendicular distance from field point to infinite vortex line
% Using vector projection: r_perp = r - (r·û)û where û is unit vortex direction
r_dot_dir = r_x*dir_x + r_y*dir_y + r_z*dir_z;
r_perp_x = r_x - r_dot_dir*dir_x;
r_perp_y = r_y - r_dot_dir*dir_y;
r_perp_z = r_z - r_dot_dir*dir_z;

% Get perpendicular distance
r_perp_mag = sqrt(r_perp_x^2 + r_perp_y^2 + r_perp_z^2);

% Check if too close to vortex line
if r_perp_mag < eta
    q = zeros(3,1);
else
    % For infinite vortex line: q = (gamma/(2*pi*r_perp)) * (vortex_dir × r_perp_hat)
    % where r_perp_hat is the unit vector in the perpendicular direction
    r_perp_hat_x = r_perp_x / r_perp_mag;
    r_perp_hat_y = r_perp_y / r_perp_mag;
    r_perp_hat_z = r_perp_z / r_perp_mag;
    
    % Cross product: vortex_dir × r_perp_hat explicitly
    cross_x = dir_y*r_perp_hat_z - dir_z*r_perp_hat_y;
    cross_y = dir_z*r_perp_hat_x - dir_x*r_perp_hat_z;
    cross_z = dir_x*r_perp_hat_y - dir_y*r_perp_hat_x;
    
    % Final induced velocity
    K = gamma / (2 * pi * r_perp_mag);
    q = [cross_x * K; cross_y * K; cross_z * K];
end

end