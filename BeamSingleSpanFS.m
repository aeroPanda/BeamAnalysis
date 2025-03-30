function [M, dM_dx, Y, dY_dx, reactions, x] = BeamSingleSpanFS(L,W,F,a,b,E,I,inc)
%BeamSingleSpanPointFS
%    M_point = BeamSingleSpanPointFS(X,L,W,F,A,B,E,I)
%    Calculates moment-shear-deflection distribution for fixed-simple beam
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
M = F.*b./(2*L.^3).*(L.*b.^2 - L.^3 + x.*(3*L.^2 - b.^2)).*tfA + ...
    (F.*a.^2./(2*L.^3).*(3*L.^2 - 3*L.*x - a.*L + a.*x)).*tfB;
dM_dx = F.*b.*(3*L.^2 - b.^2)./(2*L.^3).*tfA + ...
    -(F.*a.^2.*(3*L - a))./(2*L.^3).*tfB;
Y = ( F.*b.*xA.^2./(12*E.*I.*L.^3).*(3*L.*(b.^2 - L.^2) + xA.*(3*L.^2 - b.^2)) ).*tfA + ...
    ( F.*b.*xB.^2./(12*E.*I.*L.^3).*(3*L.*(b.^2 - L.^2) + xB.*(3*L.^2 - b.^2)) - F.*(xB-a).^3./(6*E.*I) ).*tfB;
dY_dx = ( (F.*b.*x.*(x.*(3*L.^2 - b.^2) - 3*L.*(L.^2 - b.^2)))./(6*E.*I.*L.^3) + (F.*b.*x.^2.*(3*L.^2 - b.^2))./(12*E.*I.*L.^3) ).*tfA + ...
    ( (F.*b.*x.*(x.*(3*L.^2 - b.^2) - 3*L.*(L.^2 - b.^2)))./(6*E.*I.*L.^3) - (F.*(a - x).^2)./(2*E.*I) + (F.*b.*x.^2.*(3*L.^2 - b.^2))./(12*E.*I.*L.^3) ).*tfB;

M_uniform = -W./8.*(4*x.^2 - 5*L.*x + L.^2);
dM_dx_uniform = W.*(5*L - 8*x)/8;
Y_uniform = W.*x.^2./(48*E.*I).*(L-x).*(2*x-3*L);
dY_dx_uniform = (W.*x.^2.*(L - x))./(24*E.*I) + (W.*x.^2.*(3*L - 2*x))./(48*E.*I) - (W.*x.*(L - x).*(3*L - 2*x))./(24*E.*I);

M = M + M_uniform;
dM_dx = dM_dx + dM_dx_uniform;
Y = Y + Y_uniform;
dY_dx = dY_dx + dY_dx_uniform;

reactions.R1 = 5*W(:,1).*L(:,1)/8 + F(:,1).*b(:,1)./(2*L(:,1).^3) .* (3*L(:,1).^2 - b(:,1).^2);
reactions.R2 = 3*W(:,1).*L(:,1)/8 + F(:,1).*a(:,1).^2./(2*L(:,1).^3) .* (3*L(:,1) - a(:,1));
reactions.M1 = -( W(:,1).*L(:,1).^2/8 + F(:,1).*b(:,1)./(2*L(:,1).^2) .* (L(:,1).^2 - b(:,1).^2) );
reactions.M2 = zeros(s1_L,1);
end
