classdef Model
    %MODEL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Wings;
               
        RingNodes;
        Normal;
        Collocation;
        
        TENodes;
        TERings;
        TEidx;
        
        AIC;       
        
        Gamma; 
        V;
        V_body;
        
        HasResult = false;
        NPanels_hid;
        Centroid_hid;
        
        Name = '';
    end
    
    properties(Dependent)
       NPanels
       Centroid
       Panels
       Nodes
       PanelNormal
       StripIDs
       isTE
       isLE
       Normalwash
       Area
       PanelChord;
       PanelSpan;
       Connectivity;
    end
    
    %dependent properties
    methods
        function val = get.NPanels(obj)
            val = sum([obj.Wings.NPanels]);
        end
        function val = get.Connectivity(obj)
           val = cat(2,obj.Wings.Connectivity);
           np = [obj.Wings.NPanels];
           idx = cumsum([0,[obj.Wings.NPanels]]);
           for i = 1:length(np)
               val(:,idx(i)+1:idx(i+1)) = val(:,idx(i)+1:idx(i+1)) + ...
                   repmat(idx(i),4,np(i));
           end
        end
        function val = get.PanelChord(obj)
            val = cat(1,obj.Wings.PanelChord);
        end
        function val = get.PanelSpan(obj)
            val = cat(1,obj.Wings.PanelSpan);
        end
        function val = get.Centroid(obj)
            val = [obj.Wings.Centroid];
        end
        function val = get.Panels(obj)
            val = cat(2,obj.Wings.Panels);
            np = [obj.Wings.NPanels];
            node_idx = cumsum([0,[obj.Wings.NNodes]]);
            idx = cumsum([0,[obj.Wings.NPanels]]);
            for i = 1:length(np)
                val(:,idx(i)+1:idx(i+1)) = val(:,idx(i)+1:idx(i+1)) + ...
                   repmat(node_idx(i),4,np(i));
            end
        end
        function val = get.Nodes(obj)
            val = cat(2,obj.Wings.Nodes);
        end
        function val = get.Normal(obj)
           val = [obj.Wings.Normal];
        end
        function val = get.isTE(obj)
            val = cat(1,obj.Wings.isTE);
        end
        function val = get.isLE(obj)
            val = cat(1,obj.Wings.isLE);
        end
        function val = get.Normalwash(obj)
            val = cat(1,obj.Wings.Normalwash);
        end
        function val = get.Area(obj)
            val = cat(1,obj.Wings.Area);
        end
    end
    
    methods
        function val = Get_Prop(obj,propName)
            val = zeros(obj.NPanels,1);
            idx = 1;
            for i = 1:length(obj.Wings)
               N = obj.Wings(i).NPanels;
               val(idx:idx+N-1) = obj.Wings(i).(propName);
               idx = idx + N;
            end
        end
        
        function res = get_forces_and_moments(obj,p)
           %get_forces_and_moments get forces and moments about point p
           L_wings = obj.Normal .* repmat(obj.Get_Prop('L')',3,1);
           F_wings = sum(L_wings,2);
            
           M = sum(cross(obj.Collocation-p,L_wings),2);
           res = [F_wings;M];
        end
        
        function obj = solve(obj,V,rho,V_body)
            if isa(V,'function_handle')
                obj.V = V;
            elseif length(V) == 1
                obj.V = @(X)[ones(1,size(X,2))*-V;zeros(2,size(X,2))];
            elseif length(V) == 3
                obj.V = @(X)repmat(V(:),1,size(X,2));
            else
                error('Unsupported V')
            end
            
            if ~exist('V_body','var')
                obj.V_body = @(X)zeros(3,size(X,2));
            else
                obj.V_body = V_body;
            end
            
            
            q = obj.V(obj.Collocation)+obj.V_body(obj.Collocation);
            rhs = dot(q,obj.Normal)'-q(1,:)'.*sind(obj.Normalwash);
            obj.Gamma = obj.AIC\rhs;   
            
            v_i=zeros(3,obj.NPanels);
            for i = 1:obj.NPanels
               v_i(:,i) = laca.vlm.vlm_C_code('induced_velocity',...
                obj.Collocation(:,i),obj.Panels,obj.RingNodes,obj.TERings,...
                obj.TENodes,obj.TEidx,obj.Gamma);
            end
            %apply gamma back onto sections
            idx = 1;
            for i = 1:length(obj.Wings)
               N = obj.Wings(i).NPanels;
               obj.Wings(i) = obj.Wings(i).apply_result(obj.Gamma(idx:idx+N-1),obj.V,rho);
               idx = idx + N;
            end
            obj.HasResult = true;
        end
        function obj = Stitch(obj)
           obj.Wings = arrayfun(@(x)x.Stitch,obj.Wings); 
        end
        function obj = CombineWings(obj,idx)
            idx_to_keep = setdiff(1:length(obj.Wings),idx);
            new_wing = laca.vlm.Wing([obj.Wings(idx).Sections]);
            obj.Wings = [new_wing,obj.Wings(idx_to_keep)];
        end
        
        function obj = Model(Wings,varargin)
            obj.Wings = Wings;
        end
        
        function plt_obj = draw(obj,varargin)
            p = inputParser;
            p.addParameter('param','')
            p.addParameter('PatchArgs',{})
            p.addParameter('Rotate',eye(3))
            p.parse(varargin{:})
            clear plt_obj
            nodes = p.Results.Rotate*obj.Nodes;
%             panels = obj.Panels;
%             for i = 1:length(panels)
%                 for j = 1:4
%                     panels(j,:,i) = panels(j,:,i)*p.Results.Rotate;
%                 end
%             end
            func = @(n)reshape(nodes(n,obj.Panels),4,[]);
            plt_obj(1) = patch(func(1),func(2),func(3),'b',p.Results.PatchArgs{:});
%             plt_obj(1).FaceAlpha = 0.6;
            if obj.HasResult && ~isempty(p.Results.param)
                plt_obj.FaceVertexCData = obj.Get_Prop(p.Results.param);
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
        
        function plt_obj = draw_rings(obj,varargin)
            p = inputParser;
            p.addParameter('Rotate',eye(3))
            p.addParameter('DrawTE',true)
            p.parse(varargin{:})
            
            ringNodes = p.Results.Rotate*obj.RingNodes;
            teNodes = p.Results.Rotate*obj.TENodes;
            
            collocation = p.Results.Rotate*obj.Collocation;
            
            if ~isempty(ringNodes)
                func = @(n)reshape(ringNodes(n,obj.Panels),4,[]);
                plt_obj(2) = patch(func(1),func(2),func(3),'b');
                plt_obj(2).FaceAlpha = 0;
                plt_obj(2).EdgeColor = [0 0 0];
                plt_obj(2).LineWidth = 2;
                
                if p.Results.DrawTE
                    func = @(n)reshape(teNodes(n,obj.TERings),4,[]);
                    plt_obj(3) = patch(func(1),func(2),func(3),'--');
                    plt_obj(3).FaceAlpha = 0;
                    plt_obj(3).EdgeColor = [0 0 0];
                    plt_obj(3).LineWidth = 1;
                end
                hold on
                plt_obj(3) = plot3(collocation(1,:)',...
                    collocation(2,:)',collocation(3,:)','xr');
            end
        end        
        
    end
    methods(Static)
        function obj = From_laca_model(lacaModel,minSpan,NChord,ignoreControlSurf)
            if length(NChord) == 1
                NChord = ones(1,length(lacaModel.Wings))*NChord;
            end
            wings = laca.vlm.Wing.empty;
            for i = 1:length(lacaModel.Wings)
                wings(i) = laca.vlm.Wing.From_laca_wing(lacaModel.Wings(i),minSpan,NChord(i),ignoreControlSurf);
            end
            obj = laca.vlm.Model(wings);
            obj.Name = lacaModel.Name;
        end
    end
end

