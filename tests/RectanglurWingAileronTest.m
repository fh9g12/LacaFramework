% generate the model
Span = 1;
NSpan = 20;
NChord = 5;
Chord = 0.1;

LE = [0 0 0;0 Span/2*(4/5) Span/2;0 0 0];
TE = LE;
TE(1,:) = -Chord;
ail = laca.model.RefControlSurf(2,ones(1,2)*0.25,'ail');
wing = laca.model.Wing.From_RHS_LE_TE(LE,TE,{ail});
vlm_wing = laca.vlm.Wing.From_laca_wing(wing,Span/NSpan,NChord,false);
model = laca.model.Aircraft({wing});
figure(1);clf;model.draw;
axis equal

% convert to VLM model
vlm_model = laca.vlm.Model.From_laca_model(model,0.025,5,false);
figure(2);clf;vlm_model.draw;
axis equal

% generate VLM rings
vlm_model = deflect_ailerons(vlm_model,0);
AoA = 5;
Beta = 0;
V_func = dcrg.rotyd(-AoA)*dcrg.rotzd(-Beta)*[-20 0 0]';
V_dir = V_func./vecnorm(V_func);
vlm_model.generate_te_horseshoe(V_dir*10);
figure(3);clf;vlm_model.draw_rings;
axis equal

% solve the model
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

%deflect the ailerons and run agian
vlm_model_ail = deflect_ailerons(vlm_model.copy(),25);
vlm_model_ail.generate_te_horseshoe(V_dir*10);
vlm_model_ail.generate_AIC();
vlm_model_ail.solve(V_func);
vlm_model_ail.apply_result_katz(1.225);
Wrench = vlm_model.get_forces_and_moments([-0.08*0.25,0,0]');
f = figure(5);clf;
vlm_model.draw('param','P');
f.CurrentAxes.ZDir = 'Reverse';
ax = gca;
ax.Clipping = 'off';
axis equal

%% check lift is the same as the generated without Ailerons ('RectanglurWingTest.m')
tol = 1e-2;
assert(abs(L--10.401)<tol,'Incorrect Lift')

%% deflect Ailerons and ensure moment in correct direction
assert(Wrench(4)<0,'Incorrect Lift')


function vlm_model = deflect_ailerons(vlm_model,ail_deflection)
for i = 1:length(vlm_model.Wings)
    for j = 1:length(vlm_model.Wings{i}.Sections)
        if ~isempty(vlm_model.Wings{i}.Sections{j}.ControlSurfaces)
            surfs = vlm_model.Wings{i}.Sections{j}.ControlSurfaces;
            for k = 1:length(surfs)
                switch surfs(k).Name
                    case 'ail_l'
                        surfs(k).Deflection = ail_deflection;
                    case 'ail_r'
                        surfs(k).Deflection = -ail_deflection;
                end
            end
            vlm_model.Wings{i}.Sections{j}.ControlSurfaces = surfs;
        end
    end
end
end