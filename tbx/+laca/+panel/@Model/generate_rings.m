function obj = generate_rings(obj)
%GENERATE_RINGS Summary of this function goes here
%   Detailed explanation goes here

[obj.Rings,obj.Normal,obj.Collocation,obj.TERings,obj.TEidx] = ...
    laca.panel.vlm_C_code('generate_rings',obj.Panels,obj.isTE);

% [obj.Rings,obj.Normal,obj.Collocation,obj.TERings,obj.TEidx] = ...
%     laca.panel.generate_rings(obj.Panels,obj.isTE);
end
