% this test generates a rectagular wing which is used to check:
% - vlm result generates correct Lift
%
% wing properties are
% - Span = 1m
% - Chord = 0.1m
% - Spanwise Panels = 40
% - Chordwise Panels = 5
%
% author: Fintan healy      Date: 19/04/2022
% email: fintan.healy@bristol.ac.uk

% generate a rectangular wing model

LE = [0 0 0;0 0.25 0.5;0 0 0];
TE = LE;
TE(1,:) = -0.1;
wing = laca.model.Wing.From_RHS_LE_TE(LE,TE,{});
model = laca.model.Aircraft({wing});
figure(1);clf;model.draw;
axis equal

% convert to VLM model
vlm_model = laca.vlm.Model.From_laca_model(model,0.025,5,true);
vlm_model.XZ_sym = false;
vlm_model.useMEX = true;
figure(2);clf;vlm_model.draw;
axis equal

% generate VLM rings
vlm_model.generate_te_horseshoe([-0.5 0 0]');
figure(3);clf;vlm_model.draw_rings;
axis equal

% test solver
AoA = 5;
Beta = 0;
V_func = dcrg.rotyd(-AoA)*dcrg.rotzd(-Beta)*[-20 0 0]';
V_dir = V_func./vecnorm(V_func);
vlm_model.set_panel_filiments();
vlm_model.generate_te_horseshoe(V_dir*5);

vlm_model.generate_AIC3D();
vlm_model.solve(V_func);
vlm_model.apply_result_katz(1.225);
Wrench = vlm_model.get_forces_and_moments([-0.08*0.25,0,0]');
F = (dcrg.rotyd(-AoA)*dcrg.rotzd(-Beta))'*Wrench(1:3);
L_katz= F(3);

f = figure(4);clf;
vlm_model.draw('param','P');
f.CurrentAxes.ZDir = 'Reverse';
ax = gca;
ax.Clipping = 'off';
axis equal
colorbar

vlm_model.apply_result_ring(1.225);
Wrench = vlm_model.get_forces_and_moments([-0.08*0.25,0,0]');
F = (dcrg.rotyd(-AoA)*dcrg.rotzd(-Beta))'*Wrench(1:3);
L_fil= F(3);

f = figure(5);clf;
vlm_model.draw('param','P');
% vlm_model.draw_rings();
f.CurrentAxes.ZDir = 'Reverse';
ax = gca;
ax.Clipping = 'off';
axis equal
colorbar


%% ensure correct lift generated (Katz)
tol = 1e-2;

assert(abs(L_katz--10.401)<tol,'Incorrect Lift')

%% ensure correct lift generated (Filiment)
tol = 1e-2;
assert(abs(L_fil--10.549)<tol,'Incorrect Lift')




