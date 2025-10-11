function q = horseshoe(coords,p,gamma)
%VORTEX_RING calculates the induced velocity at point p from a horseshoe
%vortex specified by coords with strength gamma
%   coords is a (3,4) matrix which are the N verticies of the ring in a
%   clockwise order (start from LE inboard,e.g LE->LE->TE->TE)
q = laca.vlm.vortex_line(coords(:,1),coords(:,2),p,gamma);
q = q + laca.vlm.semiinfinite_vortex_line(coords(:,1),coords(:,4),p,-gamma);
q = q + laca.vlm.semiinfinite_vortex_line(coords(:,2),coords(:,3),p,gamma);
end

