classdef Aircraft < handle
    %AIRCRAFT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Wings
        Name;
    end
    
    methods
        function cp = copy(obj)
            cp = laca.model.Aircraft(cellfun(@(x)x.copy,obj.Wings,'UniformOutput',false));
            cp.name = obj.Name;
        end
        function obj = Aircraft(Wings)
            if ~iscell(Wings)
                error('Input must be a cell array of wings')
            end
            for i = 1:length(Wings)
                if ~isa(Wings{i},'laca.model.Wing')
                    error('Input must be a cell array of wings')
                end
            end
            obj.Wings = Wings;
        end
        
        function obj = Rotate(obj,mat)
            for i = 1:length(obj.Wings)
               for j = 1:length(obj.Wings{i}.WingSections)
                   obj.Wings{i}.WingSections{j}.R = mat*obj.Wings{i}.WingSections{j}.R;
                   obj.Wings{i}.WingSections{j}.Rot = mat*obj.Wings{i}.WingSections{j}.Rot;
               end
            end
        end
        
        function obj = Rz(obj,deg)
            if deg ~= 0 
                obj.Rotate(dcrg.rotzd(deg))
            end
        end
        function obj = Ry(obj,deg)
            if deg ~= 0 
                obj.Rotate(dcrg.rotyd(deg))
            end
        end
        function obj = Rx(obj,deg)
            if deg ~= 0 
                obj.Rotate(dcrg.rotxd(deg))
            end
        end
        function out = draw(obj,varargin)
            out = cellfun(@(x)x.draw(varargin{:}),obj.Wings);
        end
        function out = ApplySplineSet(obj,varargin)
            out = obj.applyfunc(@(x)x.ApplySplineSet(varargin{:}));
        end
        function out = createStreamwiseVariant(obj,varargin)
            out = obj.applyfunc(@(x)x.createStreamwiseVariant(varargin{:}));
        end
        function out = createStreamwiseVariantv2(obj,varargin)
            out = obj.applyfunc(@(x)x.createStreamwiseVariantv2(varargin{:}));
        end
        function out = createNastranExample(obj,varargin)
            out = obj.applyfunc(@(x)x.createNastranExample(varargin{:}));
        end
        function out = split_sections(obj,varargin)
            out = obj.applyfunc(@(x)x.split_sections(varargin{:}));
        end
        function out = split_chordwise(obj,varargin)
            out = obj.applyfunc(@(x)x.split_chordwise(varargin{:}));
        end
        function out = applyfunc(obj,func,varargin)
            wings = cellfun(@(wing)func(wing,varargin{:}),obj.Wings,'UniformOutput',false);
            out = laca.model.Aircraft(wings);
        end
        
        function fe = ToFE(obj)
           fe = laca.fe.Model.FromLACA(obj); 
        end
    end
end

