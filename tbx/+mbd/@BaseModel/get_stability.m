function evs = get_stability(p,U,t) %#codegen
    % call the solver
    j = mbd.jacobiancd(@(x)p.deriv(t,x),U);
    [~,D] = eig(j);
    evs = diag(D);
end