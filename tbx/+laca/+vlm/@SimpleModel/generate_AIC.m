function obj = generate_AIC(obj)
% compute influence of wing panels
if obj.useMEX
    obj.AIC = laca.vlm.vlm_C_code('laca.vlm.generate_AIC',obj.Panels,...
        obj.RingNodes,obj.Collocation,obj.TERings,obj.TENodes,obj.TEidx,obj.XZ_sym);
    obj.AICi = laca.vlm.vlm_C_code('laca.vlm.generate_self_AIC',obj.Panels,...
        obj.RingNodes,obj.Collocation);
else
    obj.AIC = laca.vlm.generate_AIC(obj.Panels,...
        obj.RingNodes,obj.Collocation,obj.TERings,obj.TENodes,obj.TEidx,obj.XZ_sym);
    obj.AICi = laca.vlm.generate_self_AIC(obj.Panels,obj.RingNodes,obj.Collocation);
end
end

