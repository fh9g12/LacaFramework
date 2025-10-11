function obj = gen_MainWing(flare,isRight)
%GET_MAINWING Summary of this function goes here
%   Detailed explanation goes here
            
    % define one side of the wing
    LE = [0 0 0 0 0 0;...
        0,60.5,130,230,330,365;...
        0 0 0 0 0 0];
    LE = LE * 1e-3;
    chord = [80 80 80 80 80 80] * 1e-3;
    twist = [0 0 0 0 0 0];
    
    centreline = LE + repmat([0.5,0,0]',1,length(chord)).*repmat(-chord,3,1);
    TE = zeros(size(LE));
    % adjust for setting angle 
    for i = 1:length(chord)
        LE(:,i) = centreline(:,i) + [cosd(twist(i));0;-sind(twist(i))]*chord(i)/2;
        TE(:,i) = centreline(:,i) - [cosd(twist(i));0;-sind(twist(i))]*chord(i)/2;
    end
    
    %create the Flared hinge
    panel_normal = cross(LE(:,end)-LE(:,end-1),LE(:,end)-TE(:,end)); 
    if panel_normal(3)>0
        panel_normal = panel_normal*-1;
    end
    
    hinge_axis = dcrg.geom.rotateAbout([1 0 0]',panel_normal,-flare);
    if hinge_axis(1)<0
        panel_normal = panel_normal*-1;
    end
    newLE = dcrg.geom.plane_line_intersect(cross(hinge_axis,panel_normal)',...
        mean([LE(:,end),TE(:,end)]'),...
        LE(:,end)',LE(:,end-1)');
    newTE = dcrg.geom.plane_line_intersect(cross(hinge_axis,panel_normal)',...
        mean([LE(:,end),TE(:,end)]'),...
        TE(:,end)',TE(:,end-1)');

    LE(:,end) = newLE;
    TE(:,end) = newTE;  
    
    if isRight
       Name = 'Main Wing Right';
       ail_name = 'ail_r';
       ail_idx = 4;
    else
        LE(2,:) = -1 * LE(2,:); 
        TE(2,:) = -1 * TE(2,:);
        LE = fliplr(LE);
        TE = fliplr(TE);
        Name = 'Main Wing Left';
        ail_name = 'ail_l';
        ail_idx = 2;
    end

    % Define Ailerons
    ailerons = laca.model.RefControlSurf(ail_idx,[25/80,25/80],ail_name);

%     range = 801:822;
    %create object
    obj = laca.model.Wing.From_LE_TE(LE,TE,ailerons);
    obj.Name = Name;
%     obj.GridIDs = [range,range+1e3,range+1e5,range+2e5,range+101e3,range+201e3,123,201,202];
end

