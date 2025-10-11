function out = ApplySplineSet(obj,structural_file,varargin)
%APPLYSTRUCTURALGPS Summary of this function goes here
%   Detailed explanation goes here
    p = inputParser;
    p.addParameter('Beta',0)
    p.addParameter('Alpha',0)
    p.parse(varargin{:})
    
    % get the coordinates of all the structural points that can be used in
    % the splines
    load(structural_file,'model')
    coords = model.GRID.getDrawCoords('Mode','undeformed');
    coords = dcrg.rotyd(p.Results.Alpha) * dcrg.rotzd(p.Results.Beta) * coords;
    [~,i_gid,i] =intersect(obj.GridIDs,model.GRID.GID);
    coords = coords(:,i);
    GIDs = obj.GridIDs(i_gid);

    wingSections = cell2mat(cellfun(@(x)x.ApplySplineSet(coords,GIDs),obj.WingSections,'UniformOutput',false));
    % get the coordinates of all the structural points that can be used in
    % the splines
    out = obj.copy();
    out.WingSections = wingSections;
end

