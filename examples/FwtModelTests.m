LE = [zeros(1,6);0,0.05,0.15,0.25,0.3,0.5;zeros(1,6)];
TE = LE;
TE(1,:) = TE(1,:)+0.1;
Flare = 30;
Fold = 45;
Twist = 0;
ContrlDeflection = 0;

wings = FWT_Model.gen_FWT(Flare,0,Twist,false);
wings(2) = FWT_Model.gen_MainWing(Flare,false);
wings(3) = FWT_Model.gen_MainWing(Flare,true);
wings(4) = FWT_Model.gen_FWT(Flare,0,Twist,true);
model = laca.model.Aircraft(wings);
model.Name = 'AlphaBeta';
sections = [model.Wings.WingSections];
sections(strcmp(string({sections.ControlName}),"ail_r")).ControlDeflection = ContrlDeflection;
sections(strcmp(string({sections.ControlName}),"ail_l")).ControlDeflection = ContrlDeflection;


f = figure(1);clf;
model.draw
f.CurrentAxes.ZDir = 'Reverse';
ax = gca;
ax.Clipping = 'off';
axis equal

%% gen vlm model
AoA = 10;
Beta = 0;
V_func = dcrg.rotzd(-AoA)*dcrg.rotzd(-Beta)*[-20 0 0]';

vlm_model = laca.vlm.Model.From_laca_model(model,0.02,5,false);

% deflect wingtips
vlm_model.Wings(1).Rot = dcrg.rotzd(-Flare)*dcrg.rotxd(Fold)*dcrg.rotzd(Flare);
vlm_model.Wings(end).Rot = dcrg.rotzd(Flare)*dcrg.rotxd(-Fold)*dcrg.rotzd(-Flare);

f = figure(2);clf;
vlm_model.draw
f.CurrentAxes.ZDir = 'Reverse';
ax = gca;
ax.Clipping = 'off';
axis equal

%% gen rings
V_dir = V_func./vecnorm(V_func);
vlm_model = vlm_model.generate_te_horseshoe(V_dir * 0.5);
f = figure(3);clf;
vlm_model.draw_rings
f.CurrentAxes.ZDir = 'Reverse';
ax = gca;
ax.Clipping = 'off';
axis equal


%% solve
vlm_model = vlm_model.generate_AIC3D();
vlm_model = vlm_model.set_panel_filiments();
vlm_model = vlm_model.solve(V_func);
vlm_model = vlm_model.apply_result_katz(1.225);


f = figure(4);clf;
subplot(2,1,1)
vlm_model = vlm_model.apply_result_katz(1.225);
vlm_model.draw('param','Cp','Rotate',dcrg.rotzd(90))
f.CurrentAxes.ZDir = 'Reverse';
ax = gca;
ax.Clipping = 'off';
axis equal
subplot(2,1,2)
vlm_model = vlm_model.apply_result_ring(1.225);
vlm_model.draw('param','Cp','Rotate',dcrg.rotzd(90))
f.CurrentAxes.ZDir = 'Reverse';
ax = gca;
ax.Clipping = 'off';
axis equal
% for y = -0.55:0.275:0.55
%     for z = -0.1:0.1:0.1
%         vlm_model.draw_streamline([0.2,y,z]')
%     end
% end


f.CurrentAxes.ZDir = 'Reverse';
ax = gca;
ax.Clipping = 'off';
axis equal

