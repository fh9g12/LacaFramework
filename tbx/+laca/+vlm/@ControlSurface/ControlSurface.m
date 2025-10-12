classdef ControlSurface < handle
    %CONTROLSURFACE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Name = '';
        Type = '';
        Side = laca.vlm.Side.Starboard;
        HingeNodes = [];
        Nodes = [];
        Panels = [];
        NControl;
        Idx = 0;
        Deflection = 0;
    end

    methods
        function cp = copy(obj)
            cp = laca.vlm.ControlSurface(obj.Name,obj.NControl);
            cp.Type = obj.Type;
            cp.Side = obj.Side;
            cp.HingeNodes = obj.HingeNodes;
            cp.Nodes = obj.Nodes;
            cp.Panels = obj.Panels;
            cp.NControl = obj.NControl;
            cp.Idx = obj.Idx;
            cp.Deflection = obj.Deflection;
        end
    end
    
    methods
        function obj = ControlSurface(Name,NControl)
            obj.Name = Name;
            obj.NControl = NControl;
        end
    end
    methods(Static)
        function obj = None()
            obj = laca.vlm.ControlSurface('None',0);
        end
    end
end

