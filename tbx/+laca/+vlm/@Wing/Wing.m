classdef Wing < laca.vlm.Base
    %MODEL Summary of this class goes here
    %   Detailed explanation goes here

    properties       
        Filiment_Force;
        Filiment_Position;
        Panel_Filiments;
    end
    properties(SetAccess = immutable)
        NPanels;
        NNodes;
    end
    properties(NonCopyable)
        Sections;
        Panels_cache;
    end
    properties(Dependent)
        dC_l_dalpha
        Centroid
        Normal
        Panels
        Nodes
        isTE
        isLE
        Area
        Normalwash
        Rot;
        R;
        RingNodes;
        Collocation;
        Vbody_func
        Gamma;
        N;
        L;
        D;
        S;
        F;
        Lprime;
        P;
        Cp;
        Cl;
        Cd;
        PanelChord;
        PanelSpan;
        Connectivity;
    end
    % results
    properties
        useMEX = true;
        Name = '';
        HasResult = false;
        
    end
    methods
        function set.useMEX(obj,val)
            obj.useMEX = val;
            for i = 1:length(obj.Sections)
                obj.Sections{i}.useMEX = val;
            end
        end
      function cp = copy(obj)
         % Shallow copy object
         cp = laca.vlm.Wing(cellfun(@(x)x.copy,obj.Sections,'UniformOutput',false));
         cp.useMEX = obj.useMEX;
         cp.HasResult = obj.HasResult;
         cp.Name = obj.Name;
         cp.Filiment_Force = obj.Filiment_Force;
         cp.Filiment_Position = obj.Filiment_Position;
         cp.Panel_Filiments = obj.Panel_Filiments;
      end
   end

    %dependent properties
    methods
        function set.Vbody_func(obj,val)
            for i = 1:length(obj.Sections)
                obj.Sections{i}.Vbody_func = val;
            end
        end
        function set.Rot(obj,val)
            for i = 1:length(obj.Sections)
                obj.Sections{i}.Rot = val;
            end
        end
        function set.R(obj,val)
            for i = 1:length(obj.Sections)
                obj.Sections{i}.R = val;
            end
        end
        function val = get.Connectivity(obj)
            res = cellfun(@(x)x.Connectivity,obj.Sections,'UniformOutput',false);
            val = cat(2,res{:});
            np = cellfun(@(x)x.NPanels,obj.Sections);
            idx = cumsum([0,np]);
            for i = 1:length(np)
                val(:,idx(i)+1:idx(i+1)) = val(:,idx(i)+1:idx(i+1)) + ...
                    repmat(idx(i),4,np(i));
            end
        end
        function val = get.PanelChord(obj)
            res = cellfun(@(x)x.PanelChord,obj.Sections,'UniformOutput',false);
            val = cat(1,res{:});
        end
        function val = get.PanelSpan(obj)
            res = cellfun(@(x)x.PanelSpan,obj.Sections,'UniformOutput',false);
            val = cat(1,res{:});
        end
        function val = get.Centroid(obj)
            res = cellfun(@(x)x.Centroid,obj.Sections,'UniformOutput',false);
            val = cat(2,res{:});
        end
        function val = get.Panels(obj)
            if ~isempty(obj.Panels_cache)
                val = obj.Panels_cache;
            else
            res = cellfun(@(x)x.Panels,obj.Sections,'UniformOutput',false);
            val = cat(2,res{:});
            np = cellfun(@(x)x.NPanels,obj.Sections);
            node_idx = cumsum([0,cellfun(@(x)x.NNodes,obj.Sections)]);
            idx = cumsum([0,np]);
            for i = 1:length(np)
                val(:,idx(i)+1:idx(i+1)) = val(:,idx(i)+1:idx(i+1)) + ...
                    repmat(node_idx(i),4,np(i));
            end
            obj.Panels_cache = val;
            end
        end
        function val = get.F(obj)
            res = cellfun(@(x)x.F,obj.Sections,'UniformOutput',false);
            val = cat(2,res{:});
        end
        function val = get.dC_l_dalpha(obj)
            res = cellfun(@(x)x.dC_l_dalpha,obj.Sections,'UniformOutput',false);
            val = cat(1,res{:});
        end
        function val = get.Gamma(obj)
            res = cellfun(@(x)x.Gamma,obj.Sections,'UniformOutput',false);
            val = cat(1,res{:});
        end
        function val = get.N(obj)
            res = cellfun(@(x)x.N,obj.Sections,'UniformOutput',false);
            val = cat(1,res{:});
        end
        function val = get.L(obj)
            res = cellfun(@(x)x.L,obj.Sections,'UniformOutput',false);
            val = cat(1,res{:});
        end
        function val = get.D(obj)
            res = cellfun(@(x)x.D,obj.Sections,'UniformOutput',false);
            val = cat(1,res{:});
        end
        function val = get.S(obj)
            res = cellfun(@(x)x.S,obj.Sections,'UniformOutput',false);
            val = cat(1,res{:});
        end
        function val = get.Lprime(obj)
            res = cellfun(@(x)x.Lprime,obj.Sections,'UniformOutput',false);
            val = cat(1,res{:});
        end
        function val = get.P(obj)
            res = cellfun(@(x)x.P,obj.Sections,'UniformOutput',false);
            val = cat(1,res{:});
        end
        function val = get.Cp(obj)
            res = cellfun(@(x)x.Cp,obj.Sections,'UniformOutput',false);
            val = cat(1,res{:});
        end
        function val = get.Cl(obj)
            res = cellfun(@(x)x.Cl,obj.Sections,'UniformOutput',false);
            val = cat(1,res{:});
        end
        function val = get.Cd(obj)
            res = cellfun(@(x)x.Cd,obj.Sections,'UniformOutput',false);
            val = cat(1,res{:});
        end
        function val = get.Nodes(obj)
            res = cellfun(@(x)x.Nodes,obj.Sections,'UniformOutput',false);
            val = cat(2,res{:});
        end
        function val = get.RingNodes(obj)
            res = cellfun(@(x)x.RingNodes,obj.Sections,'UniformOutput',false);
            val = cat(2,res{:});
        end
        function val = get.Collocation(obj)
            res = cellfun(@(x)x.Collocation,obj.Sections,'UniformOutput',false);
            val = cat(2,res{:});
        end
        function val = get.Normal(obj)
            res = cellfun(@(x)x.Normal,obj.Sections,'UniformOutput',false);
            val = cat(2,res{:});
        end
        function val = get.isTE(obj)
            res = cellfun(@(x)x.isTE,obj.Sections,'UniformOutput',false);
            val = cat(1,res{:});
        end
        function val = get.isLE(obj)
            res = cellfun(@(x)x.isLE,obj.Sections,'UniformOutput',false);
            val = cat(1,res{:});
        end
        function val = get.Area(obj)
            res = cellfun(@(x)x.Area,obj.Sections,'UniformOutput',false);
            val = cat(1,res{:});
        end
        function val = get.Normalwash(obj)
            res = cellfun(@(x)x.Normalwash,obj.Sections,'UniformOutput',false);
            val = cat(1,res{:});
        end
    end

    methods
        function clearCache(obj)
            obj.Panels_cache = [];
        end
        function val = Vbody(obj,U)
            val = [];
            for i = 1:length(obj.Sections)
                val = [val,obj.Sections{i}.Vbody(U)];
            end
        end
        function obj = Stitch(obj)
            for i = 1:length(obj.Sections)-1
                % get rhs panels
                sec_lhs = obj.Sections{i};
                con_lhs = sec_lhs.Connectivity;
                lhs_idx = find(isnan(con_lhs(2,:)));
                N_lhs = size(con_lhs,2);

                % get lhs panels
                sec_rhs = obj.Sections{i+1};
                con_rhs = sec_rhs.Connectivity;
                rhs_idx = find(isnan(con_rhs(4,:)));

                %stitch together lhs and rhs
                for j = 1:length(lhs_idx)
                    con_lhs(2,lhs_idx(j)) = N_lhs + rhs_idx(j);
                    con_rhs(4,rhs_idx(j)) = lhs_idx(j) - N_lhs - 1;
                end

                obj.Sections{i+1}.Connectivity = con_rhs;
                obj.Sections{i}.Connectivity = con_lhs;
            end
        end
    end


    % apply results
    methods
        function obj = apply_result_katz(obj,gamma,V,rho)
            Lift = -obj.Lift_katz(gamma,V,rho);
            idx = 1;
            for i = 1:length(obj.Sections)
                pN = obj.Sections{i}.NPanels;
                obj.Sections{i}.apply_result_katz(...
                    gamma(idx:idx+pN-1),...
                    -Lift(idx:idx+pN-1),V,rho);
                idx = idx + pN;
            end
        end
        function L = Lift_katz(obj,gamma,V,rho)
            Vs = V(obj.Centroid);
            L = rho .* vecnorm(Vs)' .* obj.PanelSpan;
            Con = obj.Connectivity;

            idx = ~isnan(Con(1,:));
            gamma = obj.Gamma;
            gamma(idx) = (gamma(idx)-gamma(Con(1,idx)));
            L = L.*gamma;
        end
    end

    methods
        function obj = Wing(Sections,varargin)
            if ~iscell(Sections)
                error('Input must be a cell array of WingSections')
            end
            for i = 1:length(Sections)
                if ~isa(Sections{i},'laca.vlm.Section')
                    error('Input must be a cell array of WingSections')
                end
            end
            obj.Sections = Sections;
            obj.NPanels = sum(cellfun(@(x)x.NPanels,obj.Sections));
            obj.NNodes = sum(cellfun(@(x)x.NNodes,obj.Sections));
        end

    end
    methods(Static)
        function obj = From_laca_wing(lacaWing,minSpan,NChord,ignoreControlSurf)
            sections = {};
            for i = 1:length(lacaWing.WingSections)
                sections{end+1} = laca.vlm.Section.From_laca_section(...
                    lacaWing.WingSections{i},minSpan,NChord,...
                    ignoreControlSurf);
            end
            obj = laca.vlm.Wing(sections);
        end
        function obj = From_LE_TE(LE,TE,NChord)
            obj = laca.vlm.Section.From_LE_TE(LE,TE,NChord);
        end
    end
end

