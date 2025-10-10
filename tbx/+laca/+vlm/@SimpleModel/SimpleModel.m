classdef SimpleModel < laca.vlm.Base
    %MODEL Summary of this class goes here
    %   Detailed explanation goes here

    properties
        useMEX = true;
        TENodes;
        TERings;
        TEidx;

        Filiment_Force;
        Filiment_Position;
        Panel_Filiments;

        AIC;
        AICi;
        AIC3D;

        Gamma;
        V;
        V_i;
        V_col;

        isStitch = true;

        HasKatzResult = false;
        HasFilResult = false;
        Name = '';
        WingIDs;
        XZ_sym = false;
    end

    properties(SetAccess = private)
        F;
        L;
        D;
        S;

        Cp;
        Cl;
        Cd;
        P;
        Lprime;
    end
    properties
        Filiment_tol = 0.2;
    end

    properties
        dC_l_dalpha
        NPanels
        Centroid
        Panels
        Nodes
        StripIDs
        isTE
        isLE
        Normalwash
        Area
        PanelChord;
        PanelSpan;
        Connectivity;
        RingNodes;
        Normal;
        Collocation;
    end

    % apply results
    methods
        function obj = apply_result_katz(obj,rho)
            % calc effective velocity ateach Panel

            Vs = obj.V(obj.Collocation);
            Vi = Vs + obj.Normal.*((obj.AIC-obj.AICi)*obj.Gamma)';

            % correct gammas for connected panels
            Con = obj.Connectivity;
            gamma_eff = obj.Gamma;
            gamma = obj.Gamma;

            idx = ~isnan(Con(1,:));
            gamma_eff(idx) = (gamma(idx)-gamma(Con(1,idx)));
            

            % calculate vortex filiment direction
            A = obj.Nodes(:,obj.Panels(1,:));
            B = obj.Nodes(:,obj.Panels(2,:));
            n = B-A;

            % calculate local lift vector
            obj.F = rho*cross(Vi,gamma_eff'.*n);

            %project in global lift direction
            D_hat = Vs./vecnorm(Vs); 
            obj.D = D_hat .* dot(obj.F,D_hat);
            L_hat = cross(D_hat,n)./vecnorm(n);
            obj.L = L_hat .* dot(obj.F,L_hat);
            % test = dot(obj.L,obj.D);
            % if any(abs(test) > ))
            %     warning('Lift and Drag not orthogonal')
            % end
            obj.S = obj.F - obj.L - obj.D;

            % calc normalised values
            obj.P = -dot(obj.Normal,obj.F)'./obj.Area;
            obj.Lprime = -dot(obj.Normal,obj.L)./obj.Area; 
            q = (0.5*rho*vecnorm(Vs).^2)';
            obj.Cp = obj.P./q;
            obj.Cl = obj.F(3,:)./(q.*obj.Area);
            obj.Cd = obj.F(1,:)./(q.*obj.Area);

            obj.HasKatzResult = true;
        end
    end

    methods
        function val = Get_Prop(obj,propName)
            val = zeros(obj.NPanels,1);
            idx = 1;
            for i = 1:length(obj.Wings)
                N = obj.Wings{i}.NPanels;
                val(idx:idx+N-1) = obj.Wings{i}.(propName);
                idx = idx + N;
            end
        end
        function val = Vbody(obj,U)
            val = [];
            for i = 1:length(obj.Wings)
                val = [val,obj.Wings{i}.Vbody(U)];
            end
        end
        function res = get_forces_and_moments(obj,p)
            %get_forces_and_moments get forces and moments about point p
            if obj.HasKatzResult
                L_wings = obj.Normal .* repmat(obj.Get_Prop('L')',3,1);
                pos = obj.Collocation;
            elseif obj.HasFilResult
                L_wings = obj.Filiment_Force;
                pos = laca.vlm.panel_compass(obj.Panels,obj.RingNodes);
            else
                error('No result')
            end
            F_wings = sum(L_wings,2);
            M = sum(cross(pos-p,L_wings),2);
            res = [F_wings;M];
        end
        function obj = set_panel_filiments(obj)
            if obj.useMEX
                [obj.Filiment_Position,obj.Panel_Filiments] = ...
                    laca.vlm.vlm_C_code('laca.vlm.get_perimeter_filiments',...
                    obj.Panels,obj.RingNodes,obj.Filiment_tol,obj.isTE);
            else
                [obj.Filiment_Position,obj.Panel_Filiments] = ...
                    laca.vlm.get_perimeter_filiments(...
                    obj.Panels,obj.RingNodes,obj.Filiment_tol,obj.isTE);
            end
        end

        

        function obj = solve(obj,V,U)
            if isa(V,'function_handle')
                obj.V = V;
            elseif length(V) == 1
                obj.V = @(X)[ones(1,size(X,2))*-V;zeros(2,size(X,2))];
            elseif length(V) == 3
                obj.V = @(X)repmat(V(:),1,size(X,2));
            else
                error('Unsupported V')
            end

            if exist('U','var')
                obj.V_col = obj.V(obj.Collocation) - obj.Vbody(U);
            else
                obj.V_col = obj.V(obj.Collocation);
            end
            if obj.useMEX
                obj.Gamma = laca.vlm.vlm_C_code('laca.vlm.get_gamma',obj.V_col,obj.Normal,obj.Normalwash,obj.AIC);
            else
                obj.Gamma = laca.vlm.get_gamma(obj.V_col,obj.Normal,obj.Normalwash,obj.AIC);
            end
        end
        function obj = Stitch(obj)
            obj.Wings = cellfun(@(x)x.Stitch,obj.Wings,'UniformOutput',false);
        end
        function obj = CombineWings(obj,idx)
            idx_to_keep = setdiff(1:length(obj.Wings),idx);
            new_wing = laca.vlm.Wing([obj.Wings{idx}.Sections]);
            obj.Wings = {new_wing,obj.Wings{idx_to_keep}};
        end

        function obj = SimpleModel()
        end

        function plt_obj = draw(obj,opts)
            arguments
                obj
                opts.param = ''
                opts.PatchArgs = {}
                opts.Rotate = eye(3)
            end
            nodes = opts.Rotate*obj.Nodes;
            func = @(n)reshape(nodes(n,obj.Panels),4,[]);
            plt_obj(1) = patch(func(1),func(2),func(3),'b',opts.PatchArgs{:});
            %             plt_obj(1).FaceAlpha = 0.6;
            if (obj.HasKatzResult || obj.HasFilResult) && ~isempty(opts.param)
                plt_obj.FaceVertexCData = obj.(opts.param);
                plt_obj.FaceColor = 'flat';
            end
        end

        function plt_obj = draw_streamline(obj,point,varargin)
            p = inputParser;
            p.addParameter('iter',500)
            p.addParameter('timeStep',1e-3)
            p.addParameter('Rotate',eye(3))
            p.parse(varargin{:})

            res = zeros(3,p.Results.iter+1);
            res(:,1) = point;
            for i = 1:p.Results.iter
                v_i = obj.generate_AIC_mex('induced_velocity',...
                    res(:,i),obj.Rings,obj.TERings,obj.TEidx,obj.Gamma);
                res(:,i+1) = res(:,i) + ...
                    (obj.V(res(:,i))*-1+v_i).*p.Results.timeStep;
            end
            res = p.Results.Rotate * res;
            plt_obj = plot3(res(1,:)',res(2,:)',res(3,:)','r-');
        end

        function plt_obj = draw_rings(obj,opts)
            arguments
                obj
                opts.Rotate = eye(3);
                opts.DrawTE = true;
                opts.LineWidth = 2; 
            end

            ringNodes = opts.Rotate*obj.RingNodes;
            teNodes = opts.Rotate*obj.TENodes;

            collocation = opts.Rotate*obj.Collocation;

            if ~isempty(ringNodes)
                func = @(n)reshape(ringNodes(n,obj.Panels),4,[]);
                plt_obj(2) = patch(func(1),func(2),func(3),'b');
                plt_obj(2).FaceAlpha = 0;
                plt_obj(2).EdgeColor = [0 0 0];
                plt_obj(2).LineWidth = opts.LineWidth;

                if opts.DrawTE
                    func = @(n)reshape(teNodes(n,obj.TERings),4,[]);
                    plt_obj(3) = patch(func(1),func(2),func(3),'--');
                    plt_obj(3).FaceAlpha = 0;
                    plt_obj(3).EdgeColor = [0 0 0];
                    plt_obj(3).LineWidth = opts.LineWidth*0.5;
                end
                hold on
                plt_obj(3) = plot3(collocation(1,:)',...
                    collocation(2,:)',collocation(3,:)','xr');
            end
        end

    end
    methods(Static)
        function obj = from_model(fullModel)
            obj = laca.vlm.SimpleModel();
            obj.useMEX = fullModel.useMEX;
            obj.TENodes = fullModel.TENodes;
            obj.TERings = fullModel.TERings;
            obj.TEidx = fullModel.TEidx;

            obj.Name = fullModel.Name;
            obj.Filiment_tol = fullModel.Filiment_tol; 
            obj.XZ_sym = fullModel.XZ_sym;

            obj.dC_l_dalpha = fullModel.dC_l_dalpha;
            obj.NPanels = fullModel.NPanels;
            obj.Centroid = fullModel.Centroid;
            obj.Panels = fullModel.Panels;
            obj.Nodes = fullModel.Nodes;
            obj.StripIDs = fullModel.StripIDs;
            obj.isTE = fullModel.isTE;
            obj.isLE = fullModel.isLE;
            obj.Normalwash = fullModel.Normalwash;
            obj.Area = fullModel.Area;
            obj.PanelChord = fullModel.PanelChord;
            obj.PanelSpan = fullModel.PanelSpan;
            obj.Connectivity = fullModel.Connectivity;
            obj.RingNodes = fullModel.RingNodes;
            obj.Normal = fullModel.Normal;
            obj.Collocation = fullModel.Collocation;

            vals = [0,cumsum(cellfun(@(x)x.NPanels,fullModel.Wings))];
            obj.WingIDs = {};
            for i = 2:length(vals)
                obj.WingIDs{i} = (vals(i-1)+1):vals(i);
            end
        end
    end
end

