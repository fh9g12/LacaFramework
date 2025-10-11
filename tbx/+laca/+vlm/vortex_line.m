function [q] = vortex_line(p1,p2,p_i,gamma,eta)
%VORTEX_LINE calculates the induced velocity at point p from a vortex line
%between p1 and p2 with strenth gamma (right hand rule from p1 -> p2)
if nargin < 5
    eta = 1e-6;
end

% Calculate common vector components once
r1_x = p_i(1) - p1(1);
r1_y = p_i(2) - p1(2);
r1_z = p_i(3) - p1(3);
r2_x = p_i(1) - p2(1);
r2_y = p_i(2) - p2(2);
r2_z = p_i(3) - p2(3);
r0_x = p2(1) - p1(1);
r0_y = p2(2) - p1(2);
r0_z = p2(3) - p1(3);

% get cross product of r1 and r2 using pre-calculated components
r1cr2_x = r1_y*r2_z - r1_z*r2_y;
r1cr2_y = r1_z*r2_x - r1_x*r2_z;
r1cr2_z = r1_x*r2_y - r1_y*r2_x;

% get square of norm of cross product
r1cr2_sq = r1cr2_x*r1cr2_x + r1cr2_y*r1cr2_y + r1cr2_z*r1cr2_z;

% get r1 and r2 distances using pre-calculated components
r1 = sqrt(r1_x*r1_x + r1_y*r1_y + r1_z*r1_z);
r2 = sqrt(r2_x*r2_x + r2_y*r2_y + r2_z*r2_z);

% check not too close to vortex
if r1<eta || r2<eta || r1cr2_sq < eta*eta
    q = zeros(3,1);
else
    % get dot product r_0.r_1 and r_0.r_2 using pre-calculated components
    dr1 = r0_x*r1_x + r0_y*r1_y + r0_z*r1_z;
    dr2 = r0_x*r2_x + r0_y*r2_y + r0_z*r2_z;
    
    %get induced Velocity
    K = gamma/(4*pi*r1cr2_sq)*(dr1/r1-dr2/r2);
    q = [r1cr2_x*K; r1cr2_y*K; r1cr2_z*K];
end

end

