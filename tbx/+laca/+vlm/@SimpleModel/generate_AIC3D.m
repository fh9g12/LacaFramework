function obj = generate_AIC3D(obj)
% compute influence of wing panels
if obj.useMEX
[obj.AIC3D,obj.AIC] = laca.vlm.vlm_C_code('laca.vlm.generate_AIC3D',obj.Panels,...
    obj.RingNodes,obj.Collocation,obj.TERings,obj.TENodes,obj.TEidx,obj.XZ_sym);
else
[obj.AIC3D,obj.AIC] = laca.vlm.generate_AIC3D(obj.Panels,...
    obj.RingNodes,obj.Collocation,obj.TERings,obj.TENodes,obj.TEidx,obj.XZ_sym);
end
end

