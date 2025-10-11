function [q] = semiinfinite_vortex_line(p1,p2,p_i,gamma,eta)
%SEMIINFINITE_VORTEX_LINE calculates the induced velocity at point p_i from a 
%semi-infinite vortex line starting at p1 and extending to infinity in the 
%direction (p2-p1) with strength gamma (right hand rule from p1 -> infinity)
%
% Inputs:
%   p1    - Starting point of the semi-infinite vortex line (3x1)
%   p2    - Point defining direction of vortex line (3x1) 
%   p_i   - Field point where velocity is calculated (3x1)
%   gamma - Vortex strength (scalar)
%   eta   - Cutoff distance to avoid singularities (optional, default 1e-6)
%
% Output:
%   q     - Induced velocity vector at p_i (3x1)

if nargin < 5
    eta = 1e-6;
end

% Get vortex line direction vector (from p1 towards infinity)
dir_x = p2(1) - p1(1);
dir_y = p2(2) - p1(2);
dir_z = p2(3) - p1(3);
dir_mag = sqrt(dir_x^2 + dir_y^2 + dir_z^2);
dir_x = dir_x / dir_mag; % Normalize
dir_y = dir_y / dir_mag;
dir_z = dir_z / dir_mag;

% Vector from starting point p1 to field point
r1_x = p_i(1) - p1(1);
r1_y = p_i(2) - p1(2);
r1_z = p_i(3) - p1(3);

% Get cross product vortex_dir × r1 explicitly (for correct circulation direction)
r1cr_x = dir_y*r1_z - dir_z*r1_y;
r1cr_y = dir_z*r1_x - dir_x*r1_z;
r1cr_z = dir_x*r1_y - dir_y*r1_x;

% Get square of norm of cross product
r1cr_sq = r1cr_x^2 + r1cr_y^2 + r1cr_z^2;

% Get distance from p1 to field point
r1_mag = sqrt(r1_x^2 + r1_y^2 + r1_z^2);

% Check if too close to vortex line
if r1_mag < eta || r1cr_sq < eta^2
    q = zeros(3,1);
else
    % Get dot product r1 · vortex_dir (projection along vortex direction)
    r1_dot_dir = r1_x*dir_x + r1_y*dir_y + r1_z*dir_z;
    
    % For semi-infinite vortex from p1 to infinity:
    % K = gamma/(4*pi*|r1 × dir|²) * (r1·dir/|r1| + 1)
    % The "+1" term comes from the infinity limit
    K = gamma / (4 * pi * r1cr_sq) * (r1_dot_dir / r1_mag + 1);
    
    % Final induced velocity
    q = [r1cr_x * K; r1cr_y * K; r1cr_z * K];
end

end