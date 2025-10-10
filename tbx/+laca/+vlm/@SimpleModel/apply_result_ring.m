function obj = apply_result_ring(obj,rho)
if isempty(obj.Gamma)
    error('VLM model must first be solved to apply result')
end
Vi = pagemtimes(obj.AIC3D,obj.Gamma);
obj.V_i = reshape(Vi,[],3)' + obj.V_col;
if obj.useMEX
    [obj.Filiment_Force,Fs] = laca.vlm.vlm_C_code('laca.vlm.ring_force',obj.Panels,obj.Nodes,...
        obj.Panel_Filiments,obj.V_i,obj.Gamma,obj.isTE,rho);
else
    [obj.Filiment_Force,Fs] = laca.vlm.ring_force(obj.Panels,obj.Nodes,...
        obj.Panel_Filiments,obj.V_i,obj.Gamma,obj.isTE,rho);
end
idx = 1;
for i = 1:length(obj.Wings)
    N = obj.Wings{i}.NPanels;
    p_idx = ((idx-1)*4+1):((idx-1+N)*4);
    obj.Wings{i}.apply_result_filiment(...
        obj.Gamma(idx:idx+N-1),Fs(:,idx:idx+N-1),...
        obj.Filiment_Force(:,p_idx),obj.V,rho);
    idx = idx + N;
end
obj.HasKatzResult = false;
obj.HasFilResult = true;
end
