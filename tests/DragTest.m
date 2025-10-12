% create LACA model for semi-span wing
AR = 10;
S = 10;

b = sqrt(AR*2);
c = S/b;

LE = [0 0;0 b/2;0 0];
TE = LE;
TE(1,:) = c;
wing = laca.model.Wing.From_LE_TE(LE,TE,{});
model = laca.model.Aircraft({wing});


% convert to VLM model, panel minspan 0.05m and 5 chordwise panels
vlm = laca.vlm.Model.From_laca_model(model,b/2/10,1,true);
vlm.XZ_sym = true;
vlm.useMEX = false;

% convert to simple model (condense panels / nodes into single matrices)
vlm_s = laca.vlm.SimpleModel.from_model(vlm);
vlm_s.generate_te_horseshoe([1;0;0]);

% test solver
AoA = 5;
V_func = dcrg.rotyd(-AoA)*[20;0;0];
V_dir = V_func./vecnorm(V_func);

vlm_s.generate_AIC();
vlm_s.solve(V_func);
vlm_s.apply_result_katz(1.225);
Wrench = vlm_s.get_forces_and_moments([0.08*0.25,0,0]');

F = (dcrg.rotyd(-AoA))'*Wrench(1:3);
% L_fil = F(3) * dcrg.tern(vlm.XZ_sym,2,1)
% D_fil = F(1) * dcrg.tern(vlm.XZ_sym,2,1)

% assert(abs(L_fil--10.56)<1e-2,'Incorrect Lift')

%% estimate trefftz drag
panels = vlm_s.Panels;
ringNodes = vlm_s.RingNodes;
teRings = vlm_s.TERings;
teNodes = vlm_s.TENodes;
te_idx = vlm_s.TEidx;
XZ_sym = vlm_s.XZ_sym;

% get normal of each wake ring
normal = laca.vlm.panel_normal(teRings,teNodes);
% get flowDir
flowDir = teNodes(:,teRings(4,1))-teNodes(:,teRings(1,1));
% project Nodes into trefftz plane
% teNodes = teNodes - flowDir*(flowDir'*teNodes);
collocation = laca.vlm.panel_centroid(teRings,teNodes);

N = size(teRings,2);
AICw = zeros(N);
for i = 1:size(te_idx,1)
    coords = teNodes(:,teRings(:,i));
    if XZ_sym
        sym_coords = [1 0 0;0 -1 0;0 0 1]*coords;
    end 
    for j = 1:N  
        v = laca.vlm.infinite_vortex_line(coords(:,2), coords(:,3), collocation(:,j), 1);
        v = v + laca.vlm.infinite_vortex_line(coords(:,1), coords(:,4), collocation(:,j), -1);
        if XZ_sym
            v = v + laca.vlm.infinite_vortex_line(sym_coords(:,2), sym_coords(:,3), collocation(:,j), -1);
            v = v + laca.vlm.infinite_vortex_line(sym_coords(:,1), sym_coords(:,4), collocation(:,j), 1);
        end
        AICw(j,i) = (v(1)*normal(1,j) + v(2)*normal(2,j) + v(3)*normal(3,j));
    end
end

% get Wake Gamma
wake_gamma = vlm_s.Gamma(vlm_s.TEidx(:,2));
wake_gamma'
% get trafftz downwash
w_t = (AICw*wake_gamma)';
% w_i = (vlm_s.AICw*vlm_s.Gamma)
% reshape(pagemtimes(vlm_s.AICi,vlm_s.Gamma),[],3)'*-2
% get segment lengths in trefftz plane
% project on trefftz plane
flowDir = teNodes(:,teRings(4,1))-teNodes(:,teRings(1,1));
teNodes = teNodes - flowDir*(flowDir'*teNodes);
ds = abs(vecnorm(teNodes(:,teRings(2,:)) - teNodes(:,teRings(1,:)))');

%calc drag
D = -1.225 * 0.5* sum(w_t(:).*wake_gamma(:).*ds(:))
sum(vlm_s.D)

sum(vlm_s.L)/sum(vlm_s.D)
sum(vlm_s.L)/sum(D)



