function [M, dM_dx, Y, dY_dx, reactions, x] = BeamSingleSpanFF(L,W,F,a,b,E,I,inc)
%BeamSingleSpanPointFF
%    M_point = BeamSingleSpanPointFF(X,L,W,F,A,B,E,I)
%    Calculates moment-shear-deflection distribution for fixed-fixed beam
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
M = ( F.*b.^2./L.^3.*(xA.*(3*a+b)-a.*L) ).*tfA + ...
    ( F.*b.^2./L.^3.*(xB.*(3*a+b)-a.*L) - F.*(xB-a) ).*tfB;
dM_dx = ( (F.*b.^2.*(3*a + b))./L.^3 ).*tfA + ...
    ( (F.*b.^2.*(3*a + b))./L.^3 - F ).*tfB;
Y = ( F.*b.^2.*xA.^2./(6*E.*I.*L.^3).*(xA.*(3*a+b)-3*a.*L) ).*tfA + ...
    ( F.*a.^2.*(L-xB).^2./(6*E.*I.*L.^3).*((L-xB).*(3*b+a)-3*b.*L) ).*tfB;
dY_dx = ( (F.*b.^2.*xA.^2.*(3*a + b))./(6*E.*I.*L.^3) - (F.*b.^2.*xA.*(3*L.*a - xA.*(3*a + b)))./(3*E.*I.*L.^3) ).*tfA + ...
    ( (F.*a.^2.*(3.*L.*b - (a + 3*b).*(L - xB)).*(2*L - 2*xB))./(6*E.*I.*L.^3) - (F.*a.^2.*(a + 3*b).*(L - xB).^2)./(6*E.*I.*L.^3) ).*tfB;

M_uniform = W/12 .* (6*L.*x - 6*x.^2 - L.^2);
dM_dx_uniform = W.*(5*L - 8*x)/8;
Y_uniform = -W.*x.^2./(24*E.*I).*(L-x).^2;
dY_dx_uniform = (W.*x.^2.*(2*L - 2*x))./(24*E.*I) - (W.*x.*(L - x).^2)./(12*E.*I);

M = M + M_uniform;
dM_dx = dM_dx + dM_dx_uniform;
Y = Y + Y_uniform;
dY_dx = dY_dx + dY_dx_uniform;

reactions.R1 = W(:,1).*L(:,1)/2 + F(:,1).*b(:,1).^2./L(:,1).^3 .* (3*a(:,1)+b(:,1));  % F.*b./L;
reactions.R2 = W(:,1).*L(:,1)/2 + F(:,1).*a(:,1).^2./L(:,1).^3 .* (3*b(:,1)+a(:,1));  % F.*a./L;
reactions.M1 = -( W(:,1).*L(:,1).^2/12 + F(:,1).*a(:,1).*b(:,1).^2./L(:,1).^2 );  % zeros(s1_L,1);
reactions.M2 = W(:,1).*L(:,1).^2/12 + ( - F(:,1).*(2*a(:,1) + b(:,1)).*b(:,1).^2./L(:,1).^2 + F(:,1).*(L(:,1)-a(:,1)) );  % zeros(s1_L,1);

end
