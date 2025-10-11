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
% clc;
display_system_info;                % show system info
show_result('',[],[],false,true);   % plot headers

show_plots = true;
nIters = 100;


%% generate the LACA Model
LE = [0 0 0 0 0 0 0;0 0.1 0.2 0.3 0.4 0.45 0.5;0 0 0 0 0 0 0];
TE = LE;
TE(1,:) = -0.1;
wings = {};
wings{1} = laca.model.Wing.From_LE_TE(LE(:,end-2:end)-repmat(LE(:,end-2),1,3),TE(:,end-2:end)-repmat(LE(:,end-2),1,3),{});
wings{1}.R = LE(:,end-2);
wings{2} = laca.model.Wing.From_LE_TE(LE(:,1:end-2),TE(:,1:end-2),{});
wings{3} = wings{2}.reflect_about_XZ();
wings{4} = wings{1}.reflect_about_XZ();
wings = fliplr(wings);

if show_plots
    model = laca.model.Aircraft(wings);
    figure(1);clf;model.draw;
    axis equal
end

%%

% convert to VLM model
vlm_model = laca.vlm.Model.From_laca_model(model,0.025,5,true);

AoA = 5;
Beta = 0;
V_func = dcrg.rotyd(-AoA)*dcrg.rotzd(-Beta)*[-20 0 0]';
V_dir = V_func./vecnorm(V_func);

%% time get result (Katz)
tic;
for i = 1:nIters
vlm_model = laca.vlm.Model.From_laca_model(model,0.025,5,true);
vlm_model.Wings{1}.Rot = dcrg.rotxd(45);
vlm_model.Wings{end}.Rot = dcrg.rotxd(-45);
end
t = toc;
show_result('Rect. Wing Katz Model Gen',nIters,t,false,false);

%% solve katz wing
for i = 1:nIters
vlm_model.generate_te_horseshoe(V_dir*5);
vlm_model.generate_AIC();
vlm_model.solve(V_func);
vlm_model.apply_result_katz(1.225);
end
t = toc;
show_result('Rect. Wing Katz Model Solve',nIters,t,false,false);
if show_plots
    f = figure(2);clf;
vlm_model.draw('param','P');
f.CurrentAxes.ZDir = 'Reverse';
ax = gca;
ax.Clipping = 'off';
axis equal
end

%% time get result (Katz + Stitched Sections)

tic;
for i = 1:nIters
vlm_model = laca.vlm.Model.From_laca_model(model,0.025,5,true);
for j = 1:4
    vlm_model.Wings{j} = laca.vlm.Wing(laca.vlm.stitch_sections([vlm_model.Wings{j}.Sections]));
end
vlm_model.Wings{1}.Rot = dcrg.rotxd(45);
vlm_model.Wings{end}.Rot = dcrg.rotxd(-45);
end
t = toc;
show_result('Katz Stitched Sections Gen',nIters,t,false,false);

%% solve katz wing Stitched Sections
for i = 1:nIters
vlm_model.generate_te_horseshoe(V_dir*5);
vlm_model.generate_AIC();
vlm_model.solve(V_func);
vlm_model.apply_result_katz(1.225);
end
t = toc;
show_result('Katz Stitched Sections Solve',nIters,t,false,false);
if show_plots
    f = figure(2);clf;
vlm_model.draw('param','P');
f.CurrentAxes.ZDir = 'Reverse';
ax = gca;
ax.Clipping = 'off';
axis equal
end


%% time get result (Filiment)
nIters = 100;
tic;
for i = 1:nIters
vlm_model = laca.vlm.Model.From_laca_model(model,0.025,5,true);
for j = 1:4
    vlm_model.Wings{j} = laca.vlm.Wing(laca.vlm.stitch_sections([vlm_model.Wings{j}.Sections]));
end
vlm_model.Wings{1}.Rot = dcrg.rotxd(45);
vlm_model.Wings{end}.Rot = dcrg.rotxd(-45);
vlm_model.set_panel_filiments();
end
t = toc;
show_result('Rect. Wing Fili Model Gen',nIters,t,false,false);

%% solve filiment wing
nIters = 100;
for i = 1:nIters
vlm_model.generate_te_horseshoe(V_dir*5);
vlm_model.generate_AIC3D();
vlm_model.solve(V_func);
vlm_model.apply_result_ring(1.225);
end
t = toc;
show_result('Rect. Wing Fili Model Solve',nIters,t,false,false);
if show_plots
    f = figure(3);clf;
vlm_model.draw('param','P');
f.CurrentAxes.ZDir = 'Reverse';
ax = gca;
ax.Clipping = 'off';
axis equal
end



