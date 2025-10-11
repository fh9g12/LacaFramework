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

LE = [0 0 0;0 0.4 0.5;0 0 0];
TE = LE;
TE(1,:) = -0.1;
wings = {};
wings{1} = laca.model.Wing.From_LE_TE(LE(:,2:3)-repmat(LE(:,2),1,2),TE(:,2:3)-repmat(LE(:,2),1,2),{});
wings{1}.R = LE(:,2);
wings{2} = laca.model.Wing.From_LE_TE(LE(:,1:2),TE(:,1:2),{});
wings{3} = wings{2}.reflect_about_XZ();
wings{4} = wings{1}.reflect_about_XZ();
wings = fliplr(wings);

model = laca.model.Aircraft(wings);
figure(1);clf;model.draw;
axis equal

% convert to VLM model
vlm_model = laca.vlm.Model.From_laca_model(model,0.025,5,true);
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
vlm_model.generate_te_horseshoe(V_dir*5);

vlm_model.generate_AIC();
vlm_model.solve(V_func);
vlm_model.apply_result_katz(1.225);
Wrench = vlm_model.get_forces_and_moments([-0.08*0.25,0,0]');
F = (dcrg.rotyd(-AoA)*dcrg.rotzd(-Beta))'*Wrench(1:3);
L= F(3);

f = figure(4);clf;
vlm_model.draw('param','P');
f.CurrentAxes.ZDir = 'Reverse';
ax = gca;
ax.Clipping = 'off';
axis equal

% rotate the winglets
winglet_model = vlm_model.copy();
winglet_model.Wings{1}.Rot = dcrg.rotxd(45);
winglet_model.Wings{end}.Rot = dcrg.rotxd(-45);
winglet_model.generate_te_horseshoe(V_dir*5);
winglet_model.generate_AIC();
winglet_model.solve(V_func);
winglet_model.apply_result_katz(1.225);
winglet_Wrench = winglet_model.get_forces_and_moments([-0.08*0.25,0,0]');

f = figure(5);clf;
winglet_model.draw_rings;
f.CurrentAxes.ZDir = 'Reverse';
ax = gca;
ax.Clipping = 'off';
axis equal

f = figure(6);clf;
winglet_model.draw('param','P');
f.CurrentAxes.ZDir = 'Reverse';
ax = gca;
ax.Clipping = 'off';
axis equal

AoA = 5;
Beta = 0;
V_func = dcrg.rotyd(-AoA)*dcrg.rotzd(-Beta)*[-20 0 0]';
V_dir = V_func./vecnorm(V_func);

winglet_filiment_model = winglet_model.copy();
winglet_filiment_model.generate_te_horseshoe(V_dir*5);
winglet_filiment_model.generate_AIC3D();
winglet_filiment_model.solve(V_func);
winglet_filiment_model.set_panel_filiments();
winglet_filiment_model.apply_result_ring(1.225);

f = figure(7);clf;
winglet_filiment_model.draw_rings;
f.CurrentAxes.ZDir = 'Reverse';
ax = gca;
ax.Clipping = 'off';
axis equal

f = figure(8);clf;
winglet_filiment_model.draw('param','P');
f.CurrentAxes.ZDir = 'Reverse';
ax = gca;
ax.Clipping = 'off';
axis equal


%% ensure left winglet touches main wing (Undeformed)
winglet_idx = find(vlm_model.Wings{1}.isLE,1,'last');
winglet_corner = vlm_model.Wings{1}.Nodes(:,vlm_model.Wings{1}.Panels(2,winglet_idx));
wing_idx = find(vlm_model.Wings{2}.isLE,1);
wing_corner = vlm_model.Wings{2}.Nodes(:,vlm_model.Wings{2}.Panels(1,wing_idx));
tol = 1e-2;
assert(all((winglet_corner-wing_corner)<tol))

%% ensure right winglet touches main wing (Undeformed)
winglet_idx = find(vlm_model.Wings{4}.isLE,1);
winglet_corner = vlm_model.Wings{4}.Nodes(:,vlm_model.Wings{4}.Panels(1,winglet_idx));
wing_idx = find(vlm_model.Wings{3}.isLE,1,'last');
wing_corner = vlm_model.Wings{3}.Nodes(:,vlm_model.Wings{3}.Panels(2,wing_idx));
tol = 1e-2;
assert(all((winglet_corner-wing_corner)<tol))

%% ensure copied model hasnt deformed origianl model
winglet_nodes_z = vlm_model.Wings{4}.Nodes(3,:);
tol = 1e-2;
assert(all(winglet_nodes_z<tol))

%% ensure correct lift generated
tol = 1e-2;
assert(abs(L--10.401)<tol,'Incorrect Lift')

%% ensure left winglet touches main wing (deformed)
winglet_idx = find(winglet_model.Wings{1}.isLE,1,'last');
winglet_corner = winglet_model.Wings{1}.Nodes(:,winglet_model.Wings{1}.Panels(2,winglet_idx));
wing_idx = find(winglet_model.Wings{2}.isLE,1);
wing_corner = winglet_model.Wings{2}.Nodes(:,winglet_model.Wings{2}.Panels(1,wing_idx));
tol = 1e-2;
assert(all((winglet_corner-wing_corner)<tol))

%% ensure right winglet touches main wing (deformed)
winglet_idx = find(winglet_model.Wings{4}.isLE,1);
winglet_corner = winglet_model.Wings{4}.Nodes(:,winglet_model.Wings{4}.Panels(1,winglet_idx));
wing_idx = find(winglet_model.Wings{3}.isLE,1,'last');
wing_corner = winglet_model.Wings{3}.Nodes(:,winglet_model.Wings{3}.Panels(2,wing_idx));
tol = 1e-2;
assert(all((winglet_corner-wing_corner)<tol))

%% ensure lift symmetric (deformed)
tol = 1e-2;
assert(winglet_Wrench(4)<tol,'Incorrect Roll Moment')




