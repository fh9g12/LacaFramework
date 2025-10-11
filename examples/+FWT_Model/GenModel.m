LE = [zeros(1,6);0,0.05,0.15,0.25,0.3,0.5;zeros(1,6)];
TE = LE;
TE(1,:) = TE(1,:)+0.1;
Flare = 30;
Fold = 60;
Twist = 10;
ContrlDeflection = 0;

wings = gen_FWT(Flare,Fold,Twist,false);
wings(2) = gen_MainWing(Flare,false);
wings(3) = gen_MainWing(Flare,true);
wings(4) = gen_FWT(Flare,Fold,Twist,true);
model = laca.model.Aircraft(wings);
model.Name = 'AlphaBeta';
sections = [model.Wings.WingSections];
% sections(strcmp(string({sections.ControlName}),"ail_r")).ControlDeflection = ContrlDeflection;
% sections(strcmp(string({sections.ControlName}),"ail_l")).ControlDeflection = ContrlDeflection;


f = figure(1);clf;
model.draw
f.CurrentAxes.ZDir = 'Reverse';
ax = gca;
ax.Clipping = 'off';
axis equal

AoA = 10;
Beta = 0;
V_func = dcrg.rotyd(-AoA)*dcrg.rotzd(-Beta)*[-20 0 0]';

vlm_model = laca.panel.Model.From_laca_model(model,0.02,5,1);
f = figure(2);clf;
vlm_model.draw
f.CurrentAxes.ZDir = 'Reverse';
ax = gca;
ax.Clipping = 'off';
axis equal

%sort out TE rings
V_dir = V_func./vecnorm(V_func);
for i = 1:size(vlm_model.TERings,3)
    vlm_model.TERings(3,:,i) = vlm_model.TERings(2,:,i) + V_dir' * 0.5;
    vlm_model.TERings(4,:,i) = vlm_model.TERings(1,:,i) + V_dir' * 0.5;
end
f = figure(3);clf;
vlm_model.draw_rings
f.CurrentAxes.ZDir = 'Reverse';
ax = gca;
ax.Clipping = 'off';
axis equal

vlm_model = vlm_model.generate_AIC();
vlm_model = vlm_model.solve(V_func,1.225);

f = figure(4);clf;
vlm_model.draw('param','P')
% for y = -0.55:0.275:0.55
%     for z = -0.1:0.1:0.1
%         vlm_model.draw_streamline([0.2,y,z]')
%     end
% end


f.CurrentAxes.ZDir = 'Reverse';
ax = gca;
ax.Clipping = 'off';
axis equal

