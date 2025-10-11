flare = 10;
c = 0.08;
NSpan = 6;
LE = [0 0 0;0 0.05+sind(flare)*c/2 0.1;0 0 0];
TE = [-c -c -c;0 0.05-sind(flare)*c/2 0.1;0 0 0];

wings{1} = laca.model.Wing.From_LE_TE(LE(:,1:2),TE(:,1:2),{});
wings{2} = laca.model.Wing.From_LE_TE(LE(:,2:3)-repmat(LE(:,2),1,2),TE(:,2:3)-repmat(LE(:,2),1,2),{});
wings{2}.R = LE(:,2);
model = laca.model.Aircraft(wings);

AoA = 3;
Beta = 0;
V_func = dcrg.rotyd(-AoA)*dcrg.rotzd(-Beta)*[-20 0 0]';
V_dir = V_func./vecnorm(V_func);
vlm_model = laca.vlm.Model.From_laca_model(model,0.1/NSpan,4,true);
vlm_model.Wings{2}.Rot = dcrg.rotzd(flare)*dcrg.rotxd(45)*dcrg.rotzd(-flare);
vlm_model.generate_te_horseshoe(V_dir*0.5);
vlm_model.generate_AIC3D();
vlm_model.solve(V_func);
vlm_model.useMEX = false;
vlm_model.Filiment_tol = 0.2;
vlm_model.set_panel_filiments();
vlm_model.useMEX = true;
vlm_model.apply_result_ring(1.225);
L_Katz = vlm_model.Get_Prop('L');

f = figure(1);clf;
plt_obj = vlm_model.draw('param','L');
plt_obj.FaceVertexCData = sum(vlm_model.Panel_Filiments)';
f.CurrentAxes.ZDir = 'Reverse';
ax = gca;
ax.Clipping = 'off';
axis equal
colorbar
