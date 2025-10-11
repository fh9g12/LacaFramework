function obj = gen_FWT(flare,fold,wingtipTwist,isRight)
    LE = [0,0,0,0,0;...
        0,35,60,85,135;...
        0,0,0,0,0] * 1e-3;
    chord = [80,80,80,80,80] * 1e-3;
    twist = [0 0 0 wingtipTwist wingtipTwist];
    LE(1,:) = LE(1,:) + chord/2; 
    % create mass objects
        
    centreline = LE + repmat([0.5,0,0]',1,length(chord)).*repmat(-chord,3,1);
    TE = zeros(size(LE));
    % adjust for setting angle 
    for i = 1:length(chord)
        LE(:,i) = centreline(:,i) + [cosd(twist(i));0;-sind(twist(i))]*chord(i)/2;
        TE(:,i) = centreline(:,i) - [cosd(twist(i));0;-sind(twist(i))]*chord(i)/2;
    end

    % ajdust wingtip for flare            
    panel_normal = cross(LE(:,end)-LE(:,end-1),LE(:,end)-TE(:,end)); 
    if panel_normal(3)>0
        panel_normal = panel_normal*-1;
    end
    hinge_axis = dcrg.geom.rotateAbout([1 0 0]',panel_normal,-flare);
    if hinge_axis(1)<0
        panel_normal = panel_normal*-1;
    end

    newLE = dcrg.geom.plane_line_intersect(cross(hinge_axis,panel_normal)',...
        mean([LE(:,1),TE(:,1)]'),...
        LE(:,1)',LE(:,2)');
    newTE = dcrg.geom.plane_line_intersect(cross(hinge_axis,panel_normal)',...
        mean([LE(:,1),TE(:,1)]'),...
        TE(:,1)',TE(:,2)');

    LE(:,1) = newLE;
    TE(:,1) = newTE; 

    % rotate the wingtip
    N = size(LE,2)-1;
    LE(:,2:end) = repmat(LE(:,1),1,N) + dcrg.geom.rotateAbout(LE(:,2:end)-repmat(LE(:,1),1,N),repmat(hinge_axis,1,N),-fold);
    TE(:,2:end) = repmat(TE(:,1),1,N) + dcrg.geom.rotateAbout(TE(:,2:end)-repmat(TE(:,1),1,N),repmat(hinge_axis,1,N),-fold);    
    
    if isRight
       Name = 'Right FWT';
       R = [-40 365 0]'*1e-3;
%        range = 823:827;
    else
        LE(2,:) = -1 * LE(2,:); 
        TE(2,:) = -1 * TE(2,:);
        LE = fliplr(LE);
        TE = fliplr(TE);
        Name = 'Left FWT';
        R = [-40 -365 0]'*1e-3;
%         range = 1823:1827;
    end
%     GridIDS = [range,range+100e3,range+200e3];
    %create object   
    obj = laca.model.Wing.From_LE_TE(LE,TE,laca.model.RefControlSurf.empty);
    obj.Name = Name;
    for i = 1:length(obj.WingSections)
        obj.WingSections(i).R = R;
    end
%     obj.GridIDs = GridIDS;
end

