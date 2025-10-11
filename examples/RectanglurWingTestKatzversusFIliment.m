% generate a rectangular wing model
LE = [0 0 0;0 0.25 0.5;0 0 0];
TE = LE;
TE(1,:) = -0.2;
LE(1,:) = [0,-0.05,-0.1];
% wing = laca.model.Wing.From_RHS_LE_TE(LE,TE,[]);

wing(1) = laca.model.Wing.From_LE_TE(LE,TE,[]);
wing(2) = wing(1).reflect_about_XZ;

% wing(1) = laca.model.Wing.From_LE_TE(LE(:,1:2),TE(:,1:2),[]);
% wing(2) = laca.model.Wing.From_LE_TE(LE(:,2:3),TE(:,2:3),[]);
model = laca.model.Aircraft(wing);
figure(1);clf;model.draw;
axis equal

% convert to VLM model
vlm_model = laca.vlm.Model.From_laca_model(model,0.025,5,true);
figure(2);clf;vlm_model.draw;
axis equal

% generate VLM rings
vlm_model = vlm_model.generate_te_horseshoe([-0.5 0 0]');
figure(3);clf;vlm_model.draw_rings;
axis equal

% test solver
AoA = 5;
Beta = 0;
V_func = dcrg.rotyd(-AoA)*dcrg.rotzd(-Beta)*[-20 0 0]';
V_dir = V_func./vecnorm(V_func);
vlm_model = vlm_model.generate_te_horseshoe(V_dir*0.5);
vlm_model = vlm_model.generate_AIC3D();
vlm_model = vlm_model.solve(V_func);


vlm_model = vlm_model.apply_result_katz(1.225);
f = figure(4);clf;
subplot(2,1,1)
vlm_model.draw('param','Cp','Rotate',dcrg.rotzd(90))
f.CurrentAxes.ZDir = 'Reverse';
ax = gca;
ax.Clipping = 'off';
axis equal
colorbar

vlm_model = vlm_model.set_panel_filiments();
vlm_model = vlm_model.apply_result_ring(1.225);
subplot(2,1,2)
vlm_model.draw('param','Cp','Rotate',dcrg.rotzd(90))
f.CurrentAxes.ZDir = 'Reverse';
ax = gca;
ax.Clipping = 'off';
axis equal
colorbar



