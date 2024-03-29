classdef Wing < handle
    %MODEL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Panels;
        Name;
    end
    
    properties(Dependent)
       IDs;
       Normalwash;
       Wkk;
    end
    methods
        function ids = get.IDs(obj)
            ids = arrayfun(@(x)x.IDs,obj.Panels,'UniformOutput',false);
            ids = cell2mat(ids');
        end
        function normalwash = get.Normalwash(obj)
            normalwash = arrayfun(@(x)x.Normalwash,obj.Panels,'UniformOutput',false);
            normalwash = cell2mat(normalwash');
        end
        function wkk = get.Wkk(obj)
            wkk = arrayfun(@(x)x.Wkk,obj.Panels,'UniformOutput',false);
            wkk = cat(1,wkk{:});
        end
    end
    
    methods
        function obj = Wing(Panels,varargin)
            %MODEL Construct an instance of this class
            %   Detailed explanation goes here
            p = inputParser;
            p.addRequired('Panels');
            p.addParameter('Name','');
            p.parse(Panels,varargin{:})
            obj.Panels = Panels;
            obj.Name = p.Results.Name;
        end
        
        function writeAeroToFile(obj,fid)
            obj.writeToFile(fid,@generate_aero_cards);
        end
        function writeSpline6ToFile(obj,fid,varargin)
            obj.writeToFile(fid,@generate_spline6_cards,varargin{:});
        end
        function writeSpline4ToFile(obj,fid,varargin)
            obj.writeToFile(fid,@generate_spline4_cards,varargin{:});
        end
        function writeSpline1ToFile(obj,fid,varargin)
            obj.writeToFile(fid,@generate_spline1_cards,varargin{:});
        end
        function setValue(obj,name,val)
            for i = 1:length(obj.Panels)
                obj.Panels(i).(name) = val;
            end
        end
    end
    
    methods(Access = private)
        function writeToFile(obj,fid,card_func,varargin)
            idx = arrayfun(@(x)isa(x,'laca.fe.ControlPanel'),obj.Panels);
            mni.printing.bdf.writeSubHeading(fid,obj.Name);
            % write main panels
            mni.printing.bdf.writeSubHeading(fid,'Fixed Aero Panels');
            mni.printing.bdf.writeColumnDelimiter(fid,'8')
            for panel = obj.Panels(~idx)
                arrayfun(@(x)x.writeToFile(fid),card_func(panel,varargin{:}));
            end
            % write Control Surfaces   
            if any(idx)
                mni.printing.bdf.writeSubHeading(fid,'Control Surfaces')
                mni.printing.bdf.writeColumnDelimiter(fid,'8')
                for panel = obj.Panels(idx)
                    arrayfun(@(x)x.writeToFile(fid),card_func(panel,varargin{:}));
                end
            end
        end
    end
    
    methods(Static)
        function obj = FromWing(lacaWing,opts)
            arguments
                lacaWing
                opts.sDensity = 0.03;
                opts.cDensity = 0.03;
                opts.ID = 1000001;
                opts.IGID = 999;
            end
            
            panels = laca.fe.Panel.empty;    
            ID = opts.ID;
            for sec = lacaWing.WingSections
                sec = sec{1};
                panels(end+1) = laca.fe.Panel(sec.LE(:,1),sec.LE(:,2),...
                    sec.MainChord(1),sec.MainChord(2),...
                    'sDensity',opts.sDensity,...
                    'cDensity',opts.cDensity,'ID',ID,...
                    'SplineSet',sec.SplineSet,'IGID',opts.IGID,...
                    'Normalwash1',sec.Normalwash(1),...
                    'Normalwash2',sec.Normalwash(2),...
                    'ClFactor1',sec.ClCorrection(1),...
                    'ClFactor2',sec.ClCorrection(2),...
                    'CmFactor1',sec.CmCorrection(1),...
                    'CmFactor2',sec.CmCorrection(2));
                if sec.hasControlSurf
                    ID = panels(end).MaxID + 1;
                    panels(end+1) = laca.fe.ControlPanel(...
                        sec.ControlLE(:,1),...
                        sec.ControlLE(:,2),...
                        sec.ControlChord(1),...
                        sec.ControlChord(2),...
                        'sDensity',opts.sDensity,...
                        'cDensity',opts.cDensity,'ID',ID,...
                        'SplineSet',sec.SplineSet,'IGID',opts.IGID,...
                        'Name',sec.ControlName,...
                        'Normalwash1',sec.Normalwash(1),...
                        'Normalwash2',sec.Normalwash(2),...
                        'ClFactor1',sec.ClCorrection(1),...
                        'ClFactor2',sec.ClCorrection(2),...
                        'CmFactor1',sec.CmCorrection(1),...
                        'CmFactor2',sec.CmCorrection(2));
                end
                ID = panels(end).MaxID+1;
            end
            obj = laca.fe.Wing(panels,'Name',lacaWing.Name);            
        end
    end
end

