function obj = apply_result_filiment(obj,rho)
if isempty(obj.Gamma)
    error('VLM model must first be solved to apply result')
end
if obj.useMEX
%     obj.Filiment_Position = laca.vlm.vlm_C_code('panel_compass',obj.Panels,obj.RingNodes);
    obj.V_i = laca.vlm.vlm_C_code('laca.vlm.induced_velocity',...
        obj.Collocation,obj.Panels,obj.RingNodes,obj.TERings,...
        obj.TENodes,obj.TEidx,obj.Gamma);
else
    obj.Filiment_Position = laca.vlm.panel_compass(obj.Panels,obj.RingNodes);
    obj.V_i = laca.vlm.induced_velocity(...
        obj.Collocation,obj.Panels,obj.RingNodes,obj.TERings,...
        obj.TENodes,obj.TEidx,obj.Gamma);
end

obj.V_i = obj.V_i + obj.V_col;
if obj.useMEX
    [obj.Filiment_Force,Fs] = laca.vlm.vlm_C_code('laca.vlm.ring_force',obj.Panels,obj.Nodes,...
        obj.Panel_Filiments,obj.V_i,obj.Gamma,obj.isTE,rho);
else
    [obj.Filiment_Force,Fs] = laca.vlm.ring_force(obj.Panels,obj.Nodes,...
        obj.Panel_Filiments,obj.V_i,obj.Gamma,obj.isTE,rho);
end
Fs = zeros(3,size(obj.Panels,2));
for i = 1:obj.NPanels
    Fs(:,i) = sum(obj.Filiment_Force(:,find(obj.Panel_Filiments(:,i))),2);
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

