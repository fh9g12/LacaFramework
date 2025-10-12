function y = Fseriesval(a,b,x,scale)
arguments
    a (:,1) double  % sine coeffs
    b (:,1) double  % cosine coeffs
    x (:,1) double  % locations to evaluate
    scale logical = true;
end
% FSERIESVAL Evaluates real Fourier series approximation at given data values
%
% Y = FSERIESVAL(A,B,X) the Fourier expansion of the form
%    y = A_0/2 + Sum_k[ A_k cos(kx) + B_k sin(kx) ]
% at the data values in the vector X.
%
% Y = FSERIESVAL(A,B,X,RESCALING) scales the X data to lie in the interval
% [-pi,pi] if RESCALING is TRUE (default).  If RESCALING is FALSE, no
% rescaling of X is performed.
%
% See also: Fseries

% scale x to [-pi,pi]
if scale
    x1 = min(x);
    x2 = max(x);
    x = pi*(2*(x-x1)/(x2-x1) - 1);
end

% make design matrix
n = numel(b);
nx = x*(1:n);
F = [0.5*ones(size(x)),cos(nx),sin(nx)];

% evaluate fit
y = F*[a;b];

end


