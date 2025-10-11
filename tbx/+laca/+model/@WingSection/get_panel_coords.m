function coords = get_panel_coords(obj)
    % GET_PANEL_COORDS returns an array of coordinate to draw the
    % wing section as a set of panels
    % the output 'res' has the shape 4,3,N, where the 1st dimension
    % is the 4 corners of each panel, the 2nd is the X Y Z pos of 
    % each corner, and the third is the number of panels.
    % the corner order goes TE->LE->LE->TE
    coords = zeros(4,3,obj.NSurfaces);

    % create the panel (working clockwise from southwest)
    coords(1,:,1) = obj.LE(1:3,1);
    coords(2,:,1) = obj.LE(1:3,2);
    coords(3,:,1) = obj.TE(1:3,2);
    coords(4,:,1) = obj.TE(1:3,1);

    %create Control Surface if this section has one
    if obj.hasControlSurf
        mid_point_1 = obj.LE(1:3,1) + ...
            (obj.TE(1:3,1)-obj.LE(1:3,1))*(1 - obj.ControlRefChord(1));
        mid_point_2 = obj.LE(1:3,2) + ...
            (obj.TE(1:3,2)-obj.LE(1:3,2))*(1 - obj.ControlRefChord(2));

        % create control surface
        coords(1,:,2) = mid_point_1;
        coords(2,:,2) = mid_point_2;
        coords(3,:,2) = obj.TE(1:3,2);
        coords(4,:,2) = obj.TE(1:3,1);
        
        %% rotate control surface
            coords(3,:,2)  = coords(1,:,2) + dcrg.geom.rotateAbout(coords(3,:,2)'-coords(1,:,2)',...
                coords(2,:,2)'-coords(1,:,2)',obj.ControlDeflection)';
            coords(4,:,2)  = coords(1,:,2) + dcrg.geom.rotateAbout(coords(4,:,2)'-coords(1,:,2)',...
                coords(2,:,2)'-coords(1,:,2)',obj.ControlDeflection)';

        %adjust the other surface
        coords(3,:,1) = mid_point_2;
        coords(4,:,1) = mid_point_1;
    end
end

