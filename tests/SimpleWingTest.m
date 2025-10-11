% this test generates a simple wing which is used to check:
% - generated AIC matrix
% - gamma / Lift produced 
% wing properties are
% - Span = 5m
% - Chord = 2m
% - Spanwise Panels = 5
% - Chordwise Panels = 1
%
% author: Fintan healy      Date: 19/04/2022
% email: fintan.healy@bristol.ac.uk

% generate a rectangular wing model
LE = [0 0;0 5;0 0];
TE = LE;
TE(1,:) = -2;
wing = laca.model.Wing.From_LE_TE(LE,TE,{});
model = laca.model.Aircraft({wing});
figure(1);clf;model.draw;
axis equal

% convert to VLM model
vlm = laca.vlm.Model.From_laca_model(model,1,1,true);
figure(2);clf;vlm.draw;
axis equal

% generate VLM rings

AoA = rad2deg(0.2);
Beta = 0;
V_func = dcrg.rotyd(-AoA)*dcrg.rotzd(-Beta)*[-1 0 0]';
V_dir = V_func./vecnorm(V_func);

vlm = vlm.generate_te_horseshoe(V_dir.*10);
figure(3);clf;vlm.draw_rings;
axis equal

% test solver
vlm.generate_AIC3D();
vlm.solve(V_func);
vlm.apply_result_katz(1.225);
Wrench = vlm.get_forces_and_moments([-2*0.25,2.5,0]');
F = (dcrg.rotyd(-AoA)*dcrg.rotzd(-Beta))'*Wrench(1:3);
L= F(3);
f = figure(4);clf;
vlm.draw('param','P');
f.CurrentAxes.ZDir = 'Reverse';
ax = gca;
ax.Clipping = 'off';
axis equal
tol = 1e-2;

% vlm_model.AIC*1e3

test_AIC = [-673.8342  188.5303   31.1407   12.0069    6.2643
  188.5303 -673.8342  188.5303   31.1407   12.0069
   31.1407  188.5303 -673.8342  188.5303   31.1407
   12.0069   31.1407  188.5303 -673.8342  188.5303
    6.2643   12.0069   31.1407  188.5303 -673.8342];

test_Gamma = [-0.5397;-0.6923;-0.7321;-0.6923;-0.5397];

test_Normal = [0	0	0	0	0; 0	0	0	0	0;-1	-1	-1	-1	-1];


%% ensure panel normals are correct
assert(max(abs(vlm.Normal - test_Normal),[],'all')<1e-4,'Incorrect Normal Vectors')

%% Check AIC MaCtrix
assert(max(abs(vlm.AIC*1e3 - test_AIC),[],'all')<1e-4,'Incorrect AIC Matric')

%% Check calculated Gamma Vector
assert(max(abs(vlm.Gamma - test_Gamma),[],'all')<1e-4,'Incorrect Gamma Matrix')

%% Check Total Lift produced
assert(abs(L--3.7607)<tol,'Incorrect Lift')




