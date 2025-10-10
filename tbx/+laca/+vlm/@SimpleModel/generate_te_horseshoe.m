function obj = generate_te_horseshoe(obj,dir)
%GENERATE_RINGS Summary of this function goes here
%   Detailed explanation goes here

if obj.useMEX
    [obj.TENodes,obj.TERings,obj.TEidx] = ...
        laca.vlm.vlm_C_code('laca.vlm.generate_te_horseshoe',obj.Panels,obj.Nodes,obj.isTE,dir);
else
    [obj.TENodes,obj.TERings,obj.TEidx] = ...
        laca.vlm.generate_te_horseshoe(obj.Panels,obj.Nodes,obj.isTE,dir);
end
end

