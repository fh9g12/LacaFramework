function Gamma = get_gamma(V_col,Normal,Normalwash,AIC)
% Expand dot product explicitly for speed
rhs = (V_col(1,:).*Normal(1,:) + V_col(2,:).*Normal(2,:) + V_col(3,:).*Normal(3,:))' - V_col(1,:)'.*sin(Normalwash);
if all(rhs==0)
    Gamma = rhs;
else
    Gamma = AIC\rhs;
end
end

