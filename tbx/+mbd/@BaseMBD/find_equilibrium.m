function y = find_equilibrium(obj,y,t)
%ENFORCE_CONSTRAINTS Summary of this function goes here
%   Detailed explanation goes here
Xs = length(y);
qs = Xs/2;
q_idx = 1:qs;

% options = optimoptions('fsolve','MaxFunctionEvaluations',2e6,'MaxIterations',1e4);
% options = optimoptions('fsolve','Algorithm','levenberg-marquardt');
options = optimoptions('fsolve','Algorithm','levenberg-marquardt','Display','off');
[delta_q,~,~,~] = fsolve(@(x)cost_UK2(obj,x,y,t,q_idx),zeros(size(y(q_idx))),options);

% options = optimoptions('lsqnonlin','Display','off','MaxFunctionEvaluations',1e6,'Algorithm','levenberg-marquardt','MaxIterations',1e6);
% [delta_q,~,~,~] = lsqnonlin(@(x)cost_UK2(obj,x,y,t,q_idx),zeros(size(y(q_idx))),[],[],options);

y(q_idx) = y(q_idx) + delta_q;
end

function [c,ceq] = fminconstr(p,delta_q,y,t,X_idx)
c= [];
y(X_idx) = y(X_idx) + delta_q(X_idx);
ceq = p.get_C(y);
end
function V = cost_UK2(obj,delta_X,y,t,X_idx)
y(X_idx) = y(X_idx) + delta_X;
V = obj.deriv_UK(t,y);
V = [V;obj.get_C(y)];
end

function res = cost_UK3(obj,delta_q,y,t,X_idx)
y(X_idx) = y(X_idx) + delta_q(X_idx);
V = obj.deriv_UK(t,y);
V = [V;obj.get_C(y)];
res = V'*V;
end

function V = cost_UK(obj,delta_q,y,t,q_idx)
y(q_idx) = y(q_idx) + delta_q;
V = obj.deriv_UK(t,y);
end
