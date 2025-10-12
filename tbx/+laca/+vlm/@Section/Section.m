classdef Section < handle
    %MODEL Summary of this class goes here
    %   Detailed explanation goes here

    properties
        Filiment_Force;
        Panel_Filiments;

        isLinearDeformation = false;
        G_col = [];
        G_Node = [];
        G_RingNodes = [];
        G_fil = []
        G_cent = [];

        Vbody_func = @(U,X)zeros(size(X));
        Flexi_func = @(U,x)x;
        Stitch_func = @(U,x)x;
        Normal_func = @(U,x)error('not implemented');
        useNormalFunc = false;
        updateNormal = true;
        U = [];
        DoFs = nan;
    end
    properties
        base_nodes;
        base_ringNodes;
        base_FilimentPosition;
        base_centroid;
        base_normal;
        Panels;
        NPanels;
        NNodes;
        PanelChord;
        PanelSpan;
        Area;
        isTE;
        isLE;
    end

    properties
        dC_l_dalpha;
        Normalwash;
        Connectivity;
        Name = '';
    end

    properties
        useMEX = true;
        Gamma;
        V;
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
    end

    properties(SetAccess = protected)
        ControlSurfaces_ = laca.vlm.ControlSurface.empty;
        Rot_ = eye(3);
        R_ = zeros(3,1);
    end
    properties(Dependent)
        ControlSurfaces
        Rot
        R
    end

    properties(Dependent)
        Filiment_Position;
        Nodes;
        Centroid;
        Midpoint;
        Normal;
        RingNodes;
        Collocation;
    end
    methods
        function SetGs(obj,spline,Dofs,idx)
            old_isLin = obj.isLinearDeformation;
            obj.DoFs = Dofs;
            obj.isLinearDeformation = false;
            obj.G_col = spline.get_G(obj.Collocation,Dofs,idx);
            obj.G_col = obj.G_col(1:3,:,:);
            obj.G_Node = spline.get_G(obj.Nodes,Dofs,idx);
            obj.G_Node = obj.G_Node(1:3,:,:);
            obj.G_RingNodes = spline.get_G(obj.RingNodes,Dofs,idx);
            obj.G_RingNodes = obj.G_RingNodes(1:3,:,:);
            obj.G_fil = spline.get_G(obj.Filiment_Position,Dofs,idx);
            obj.G_fil = obj.G_fil(1:3,:,:);
            obj.G_cent = spline.get_G(obj.Centroid,Dofs,idx);
            obj.G_cent = obj.G_cent(1:3,:,:);

            obj.isLinearDeformation = old_isLin;
        end
        function cp = copy(obj)
            cp = laca.vlm.Section(obj.Panels,obj.base_nodes,...
                obj.isLE,obj.isTE,obj.Connectivity);
            cp.Filiment_Force = obj.Filiment_Force;
            cp.Panel_Filiments = obj.Panel_Filiments;
            cp.Name = obj.Name;
            cp.Normalwash = obj.Normalwash;
            cp.Vbody_func = obj.Vbody_func;
            cp.R_ = obj.R_;
            cp.Rot_ = obj.Rot_;
        end
    end
    methods
        function val = get.ControlSurfaces(obj)
            val = obj.ControlSurfaces_;
        end
        function set.ControlSurfaces(obj,val)
            obj.ControlSurfaces_ = val;
        end
        function val = get.Rot(obj)
            val = obj.Rot_;
        end
        function set.Rot(obj,val)
            obj.Rot_ = val;
        end
        function val = get.R(obj)
            val = obj.R_;
        end
        function set.R(obj,val)
            obj.R_ = val;
        end
    end

    methods
        function val = NodesLocal(obj,val)
            for i = 1:length(obj.ControlSurfaces)
                if ~strcmp(obj.ControlSurfaces.Name,'None') && obj.ControlSurfaces.Deflection ~= 0
                    h_nodes = obj.ControlSurfaces(i).HingeNodes;
                    hinge = obj.base_nodes(:,h_nodes(2))-obj.base_nodes(:,h_nodes(1));
                    cs_nodes = obj.ControlSurfaces.Nodes;
                    origin = repmat(obj.base_nodes(:,h_nodes(1)),1,length(cs_nodes));
                    val(:,cs_nodes) = origin + dcrg.geom.rotateAbout(...
                        val(:,cs_nodes)-origin,repmat(hinge,1,length(cs_nodes)),...
                        obj.ControlSurfaces.Deflection);
                end
            end
        end
    end

    methods
        function val = Vbody(obj,U)
            if obj.isLinearDeformation
                val = reshape(pagemtimes(obj.G_col,obj.U(obj.DoFs+1:end)),3,[]);
            else
                local_col = laca.vlm.vlm_C_code('laca.vlm.get_collocation',obj.Panels,obj.NodesLocal(obj.base_nodes),obj.dC_l_dalpha);
                val = obj.Vbody_func(U,local_col);
            end
        end
        function val = get.Nodes(obj)
            val = obj.NodesLocal(obj.base_nodes);
            if obj.isLinearDeformation
                val = val + reshape(pagemtimes(obj.G_Node,obj.U(1:obj.DoFs)),3,[]);
            else
                val = obj.Flexi_func(obj.U,val);
            end
            val = obj.Rot*val + repmat(obj.R,1,size(val,2));
            val = obj.Stitch_func(obj.U,val);
        end
        function val = get.RingNodes(obj)
            val = obj.NodesLocal(obj.base_ringNodes);
            if obj.isLinearDeformation
                val = val + reshape(pagemtimes(obj.G_RingNodes,obj.U(1:obj.DoFs)),3,[]);
            else
                val = obj.Flexi_func(obj.U,val);
            end
            val = obj.Rot*val + repmat(obj.R,1,size(val,2));
            val = obj.Stitch_func(obj.U,val);
        end
        function val = get.Collocation(obj)
            if obj.useMEX
                val = laca.vlm.vlm_C_code('laca.vlm.get_collocation',obj.Panels,obj.Nodes,obj.dC_l_dalpha);
            else
                val = laca.vlm.get_collocation(obj.Panels,obj.Nodes,obj.dC_l_dalpha);
            end
            for i = 1:length(obj.ControlSurfaces)
                if ~strcmp(obj.ControlSurfaces.Name,'None') && obj.ControlSurfaces.Deflection ~= 0
                    h_nodes = obj.ControlSurfaces(i).HingeNodes;
                    tmpNodes = obj.Nodes;
                    hinge = tmpNodes(:,h_nodes(2))-tmpNodes(:,h_nodes(1));
                    cs_nodes = obj.ControlSurfaces.Panels;
                    origin = repmat(tmpNodes(:,h_nodes(1)),1,length(cs_nodes));
                    val(:,cs_nodes) = origin + dcrg.geom.rotateAbout(...
                        val(:,cs_nodes)-origin,repmat(hinge,1,length(cs_nodes)),...
                        obj.ControlSurfaces.Deflection);
                end
            end
        end

        function val = get.Centroid(obj)
            val = obj.base_centroid;
            if obj.isLinearDeformation
                val = val + reshape(pagemtimes(obj.G_cent,obj.U(1:obj.DoFs)),3,[]);
            else
                val = obj.Flexi_func(obj.U,val);
            end
            val = obj.Rot*val + repmat(obj.R,1,size(val,2));
            % val = obj.Stitch_func(obj.U,val);
        end
        function val = get.Filiment_Position(obj)
            val = obj.base_FilimentPosition;
            if obj.isLinearDeformation
                val = val + reshape(pagemtimes(obj.G_fil,obj.U(1:obj.DoFs)),3,[]);
            else
                val = obj.Flexi_func(obj.U,val);
            end
            val = obj.Rot*val + repmat(obj.R,1,size(val,2));
            val = obj.Stitch_func(obj.U,val);
        end
        function val = get.Midpoint(obj)
            val = zeros(3,2,obj.NPanels);
            val(:,1,:) = reshape(sum(reshape(obj.Nodes(:,obj.Panels(1:2,:)),3,2,[]),2),3,[])./2;
            val(:,2,:) = reshape(sum(reshape(obj.Nodes(:,obj.Panels(3:4,:)),3,2,[]),2),3,[])./2;
        end
        function val = get.Normal(obj)
            if ~obj.updateNormal
                val = obj.Rot*obj.base_normal;
            else
                if obj.useNormalFunc
                    n = obj.Normal_func(obj.U,obj.base_centroid);
                    n = n./repmat(vecnorm(n),3,1);
                    val = obj.Rot*n;
                else
                    if obj.useMEX
                        obj.base_normal = laca.vlm.vlm_C_code('laca.vlm.panel_normal',obj.Panels,obj.Nodes);
                    else
                        obj.base_normal = laca.vlm.panel_normal(obj.Panels,obj.Nodes);
                    end
                    val = obj.base_normal;
                end            
            end
        end
        function obj = Section(Panels,Nodes,isLE,isTE,Connectivity)
            %MODEL Construct an instance of this class
            %   Detailed explanation goes here
            obj.Panels = Panels;
            obj.base_nodes = Nodes;
            obj.isLE = isLE;
            obj.isTE = isTE;
            obj.Connectivity = Connectivity;
            obj.NPanels = size(Panels,2);
            obj.NNodes =  size(Nodes,2);
            obj.dC_l_dalpha = 2*pi*ones(obj.NPanels,1);

            N = reshape(sum(reshape(Nodes(:,Panels(1:2,:)),3,2,[]),2),3,[])./2;
            S = reshape(sum(reshape(Nodes(:,Panels(3:4,:)),3,2,[]),2),3,[])./2;
            E = reshape(sum(reshape(Nodes(:,Panels([1,4],:)),3,2,[]),2),3,[])./2;
            W = reshape(sum(reshape(Nodes(:,Panels(2:3,:)),3,2,[]),2),3,[])./2;

            obj.PanelChord = vecnorm(S-N)';
            obj.PanelSpan = vecnorm(E-W)';
            obj.base_centroid = (N+S)./2;

            if obj.useMEX
                obj.base_ringNodes= laca.vlm.vlm_C_code('laca.vlm.generate_rings',Panels,Nodes);
                obj.Area = laca.vlm.vlm_C_code('laca.vlm.panel_area',Panels,Nodes);
                obj.base_normal = laca.vlm.vlm_C_code('laca.vlm.panel_normal',Panels,Nodes);
                obj.base_FilimentPosition = laca.vlm.vlm_C_code('laca.vlm.panel_compass',Panels,obj.base_ringNodes);
            else
                obj.base_ringNodes = laca.vlm.generate_rings(Panels,Nodes);
                obj.Area = laca.vlm.panel_area(Panels,Nodes);
                obj.base_normal = laca.vlm.panel_normal(Panels,Nodes);
                obj.base_FilimentPosition = laca.vlm.panel_compass(Panels,obj.base_ringNodes);
            end

        end
        function obj = apply_result_katz(obj,gamma,L,V,rho)
            obj.Gamma = gamma;
            obj.V = V;
            A = obj.Nodes(:,obj.Panels(1,:));
            B = obj.Nodes(:,obj.Panels(2,:));
            n = cross(B-A,V(obj.Centroid));
            n = n./vecnorm(n);
            Fs = repmat(L(:)',3,1).*n;
            obj.F = Fs;
            obj.Filiment_Force = [];
            if obj.useMEX
                [obj.N,obj.D,obj.S,obj.L,obj.P,obj.Lprime,obj.Cp,obj.Cl,obj.Cd]...
                    = laca.vlm.vlm_C_code('laca.vlm.apply_result',Fs,V(obj.Centroid),obj.Normal,obj.Area,rho);
            else
                [obj.N,obj.D,obj.S,obj.L,obj.P,obj.Lprime,obj.Cp,obj.Cl,obj.Cd]...
                    = laca.vlm.apply_result(Fs,V(obj.Centroid),obj.Normal,obj.Area,rho);
            end
        end
    end
    methods(Static)
        obj = From_laca_section(wingSection,minSpan,NChord,ignoreControlSurf);
        obj = From_LE_TE(LE,TE,chord_eta_LHS,chord_eta_RHS,NControl,ControlDeflection,NormalWash);
    end
end


