function q = vortex_ring(coords,p,gamma)
%VORTEX_RING calculates the induced velocity at point p from a vortex ring specified by coords with strength gamma
%   coords is a (3,N) matrix which are the N verticies of the ring in a clockwise order
n_vert = size(coords,2);
idx = [1:n_vert,1];
q = zeros(3,1);
for i = 1:n_vert
   q = q + laca.vlm.vortex_line(coords(:,idx(i)),coords(:,idx(i+1)),p,gamma); 
end
end

