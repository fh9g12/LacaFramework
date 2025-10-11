delta = 0.3;
c = 1;
LE = [0 0 0;0 0.5+delta 1;0 0 0];
TE = [-c -c -c;0 0.5-delta 1;0 0 0];

flare = atand(delta*2/c);
wings = {};
wings{1} = laca.model.Wing.From_LE_TE(LE(:,1:2),TE(:,1:2),{});
wings{2} = laca.model.Wing.From_LE_TE(LE(:,2:3)-repmat(LE(:,2),1,2),TE(:,2:3)-repmat(LE(:,2),1,2),{});
wings{2}.R = LE(:,2);
model = laca.model.Aircraft(wings);

AoA = 3;
Beta = 0;
V_func = dcrg.rotyd(-AoA)*dcrg.rotzd(-Beta)*[-20 0 0]';
V_dir = V_func./vecnorm(V_func);
vlm_model = laca.vlm.Model.From_laca_model(model,0.5,1,true);
vlm_model.Wings{2}.Rot = dcrg.rotzd(flare)*dcrg.rotxd(45)*dcrg.rotzd(-flare);
vlm_model.generate_te_horseshoe(V_dir*0.5);
vlm_model.generate_AIC();
vlm_model.solve(V_func);
vlm_model.apply_result_katz(1.225);
L_Katz = vlm_model.Get_Prop('L');

f = figure(1);clf;
vlm_model.draw('param','L');
vlm_model.draw_rings;
f.CurrentAxes.ZDir = 'Reverse';
ax = gca;
ax.Clipping = 'off';
axis equal

vlm_model.set_panel_filiments();
vlm_model.apply_result_filiment(1.225);

f = figure(2);clf;
vlm_model.draw('param','N');
vlm_model.draw_rings;
f.CurrentAxes.ZDir = 'Reverse';
ax = gca;
ax.Clipping = 'off';
axis equal

vlm_model_2 = laca.vlm.Model.From_laca_model(model,0.5,3,true);
vlm_model_2.Wings{2}.Rot = dcrg.rotzd(flare)*dcrg.rotxd(45)*dcrg.rotzd(-flare);
vlm_model_2.generate_te_horseshoe(V_dir*0.5);
vlm_model_2.set_panel_filiments();

f = figure(3);clf;
vlm_model_2.draw;
vlm_model_2.draw_rings;
f.CurrentAxes.ZDir = 'Reverse';
ax = gca;
ax.Clipping = 'off';
axis equal


%% check number of filiment summing on each panel (Nchord = 1)
pos = full(sum(vlm_model.Panel_Filiments));
assert(all(abs(pos-[1 1 1 1])<1e-2))
% assert(all(abs(pos-[4 5 5 4])<1e-2))

%% check number of filiment summing on each panel (Nchord = 3)
pos = full(sum(vlm_model_2.Panel_Filiments));
assert(all(abs(pos-[1 1 2 2 2 2 1 1 2 2 2 2])<1e-2))
% assert(all(abs(pos-[6 7 7 8 5 6 7 6 8 7 6 5])<1e-2))

