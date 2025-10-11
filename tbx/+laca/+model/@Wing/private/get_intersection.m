function [int,idx] = get_intersection(line,point,normal)
import dcrg.geom.IntersectType
import dcrg.geom.plane_line_intersect
    I = zeros(size(line,2)-1,3);
    check = IntersectType.empty;
    for j = 1:size(line,2)-1
        [I(j,:),check(j)] = plane_line_intersect(normal',...
            point',line(:,j)',line(:,j+1)');
    end
    if size(line,2)-1 == 1
        idx = 1;
        int = I(1,:)';
    elseif nnz(check == IntersectType.InsideSegment) % intersect lies between the two points
        idx = find(check == IntersectType.InsideSegment,1);
        int = I(idx,:)';
    else
        % find point closet to the plane 
        dist = arrayfun(@(k)dot(line(:,k)-point,normal),1:size(line,2));
        [~,idx] = min(abs(dist));
        if dist(idx)<0
            idx = idx -1;
        end
        int = I(idx,:)';
    end
end