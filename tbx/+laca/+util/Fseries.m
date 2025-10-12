function [a,b,yfit] = Fseries(x,y,n,scale,sincos)
arguments
    x (:,1) double {mustBeReal,mustBeFinite} % x locations
    y (:,1) double {mustBeReal,mustBeFinite} % y values
    n double {mustBeInteger,mustBePositive} % order of fit
    scale logical = true;
    sincos string {mustBeMember(sincos,["sine","cos","both"])} = "both";
end
% FSERIES Computes real Fourier series approximation to a data set
%
% [A,B] = FSERIES(X,Y,N) fits an Nth order Fourier expansion of the form
%    y = A_0/2 + Sum_k[ A_k cos(kx) + B_k sin(kx) ]
% to the data in the vectors X & Y, using a least-squares fit.
%
% [A,B,YFIT] = FSERIES(X,Y,N) also returns a vector YFIT of the y values
% obtained by evaluating the fitted model at the values in X.
%
% [A,B,YFIT] = FSERIES(X,Y,N,RESCALING) scales the X data to lie in the
% interval [-pi,pi] if RESCALING is TRUE (default).  If RESCALING is
% FALSE, no rescaling of X is performed.
%
% [A,B,YFIT] = FSERIES(X,Y,N,RESCALING,TYPE) uses a sine expansion if TYPE
% is 'sin' or a cosine expansion if TYPE is 'cos'.  Both A & B are still
% returned, however A will be all zero if TYPE = 'sin' and B will be all
% zero if TYPE = 'cos'.
%
% See also: Fseriesval

if numel(x)~=numel(y)
    error('x and y must be same length')
end

% scale x to [-pi,pi]
if scale
    x1 = min(x);
    x2 = max(x);
    x = pi*(2*(x-x1)/(x2-x1) - 1);
end

% make design matrix
nx = x*(1:n);
switch sincos
    case "sine"
        F = sin(nx);
    case "cos"
        F = [0.5*ones(size(x)),cos(nx)];
    case "both"
        F = [0.5*ones(size(x)),cos(nx),sin(nx)];
end

% do fit
c = F\y;

switch sincos
    case "sine"
        a = zeros(n+1,1);
        b = c;
    case "cos"
        a = c;
        b = zeros(n,1);
    case "both"
        a = c(1:n+1);
        b = c(n+2:end);
end

% evaluate fit
yfit = F*c;
end