function [M, dM_dx, Y, dY_dx, reactions, x] = BeamSingleSpanSS(L,W,F,a,b,E,I,inc)
%BeamSingleSpanPointSS
%    M_point = BeamSingleSpanPointSS(X,L,W,F,A,B,E,I)
%    Calculates moment-shear-deflection distribution for simple-simple beam
% Original Author:  Alek Xu
% Original Date:    2025/03/29
% Last Modified On: 2025/03/30

s1_L = round( size(L,1) );  % number of analysis problems
s2_x = ceil( max( L./inc + 2 ) + 1 );  % size(x,2);  % number of beam locations
x = zeros(s1_L,s2_x);  % repmat(x,s1_L,1);
for m = 1:s1_L
    xm = linspace(0,L(m),s2_x-1);  % [0:inc:a(m), a(m), (a(m)+inc):inc:L];
    indLessEqualA = find( xm(1,1:end) <= a(m), 1, 'last' );  % indEqualA = find( x(m,1:end-1) == a(m), 1, 'last' );
    if a(m) == 0
        insertA = mean([xm(1,1) xm(1,2)]);
        x(m,1:end) = [xm(1,1), insertA, xm(1,2:end)];
    elseif xm(indLessEqualA) == a(m)
        insertA = mean([xm(1,indLessEqualA-1) xm(1,indLessEqualA)]);
        x(m,1:end) = [xm(1,1:indLessEqualA-1), insertA, xm(1,indLessEqualA:end)];
    else
        insertA = a(m);
        x(m,1:end) = [xm(1,1:indLessEqualA), insertA, xm(1,indLessEqualA+1:end)];
    end
end

z = zeros(s1_L,s2_x);
L = repmat(L,1,s2_x);
W = repmat(W,1,s2_x);
F = repmat(F,1,s2_x);
a = repmat(a,1,s2_x);
b = repmat(b,1,s2_x);
E = repmat(E,1,s2_x);
I = repmat(I,1,s2_x);

% M = zeros(s1_L,s2_x);
% dM_dx = zeros(s1_L,s2_x);
% Y = zeros(s1_L,s2_x);
% dY_dx = zeros(s1_L,s2_x);

tfA = and((z < x),(x <= a));
tfB = and((a < x),(x < L));

xA = x.*tfA;
xB = x.*tfB;
M = ( F.*b.*xA./L ).*tfA + ...
    ( F.*a./L.*(L-xB) ).*tfB;
dM_dx = ( F.*b./L ).*tfA + ...
    ( -F.*a./L ).*tfB;
Y = (F.*b.*xA./(6*E.*I.*L).*(xA.^2 + b.^2 - L.^2)).*tfA + ...
    (F.*a.*(L-xB)./(6*E.*I.*L).*(xB.^2 + a.^2 - 2*L.*xB)).*tfB;
dY_dx = ( (F.*b.*(-L.^2 + b.^2 + xA.^2))./(6*E.*I.*L) + (F.*b.*xA.^2)./(3*E.*I.*L) ).*tfA + ...
    ( -(F.*a.*(a.^2 + x.^2 - 2*L.*x))./(6*E.*I.*L) - (F.*a.*(L - x).*(2*L - 2*x))./(6*E.*I.*L) ).*tfB;

M_uniform = W.*x/2 .* (L-x);
dM_dx_uniform = W.*(L - x)/2 - (W.*x)/2;
Y_uniform = W.*x./(24*E.*I).*(2*L.*x.^2 - x.^3 - L.^3);
dY_dx_uniform = (W.*x.*(-3*x.^2 + 4*L.*x))./(24*E.*I) - (W.*(L.^3 - 2*L.*x.^2 + x.^3))./(24*E.*I);

M = M + M_uniform;
dM_dx = dM_dx + dM_dx_uniform;
Y = Y + Y_uniform;
dY_dx = dY_dx + dY_dx_uniform;

reactions.R1 = W(:,1).*L(:,1)/2 + F(:,1).*b(:,1)./L(:,1);
reactions.R2 = W(:,1).*L(:,1)/2 + F(:,end).*a(:,end)./L(:,end);
reactions.M1 = zeros(s1_L,1);
reactions.M2 = zeros(s1_L,1);

end
