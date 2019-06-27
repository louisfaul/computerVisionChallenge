function [T1, R1, T2, R2, U, V]=TR_aus_E(E)
% Diese Funktion berechnet die moeglichen Werte fuer T und R
% aus der Essentiellen Matrix

% single value decomposition of essential matrix E
[U,S,V]=svd(E);
% since U and V are already orthogonal matrices, we need to check that their determinants are equal +1
if det(U)~=1 | det(V)~=1
    % multiply U i.e V with eye matrix
    U=U*[1 0 0;0 1 0;0 0 -1];
    V=V*[1 0 0;0 1 0;0 0 -1];
end
% define two possible solutions for matrix R_z: rotation with pi/2 and -pi/2
Rz1=[0 -1 0;1 0 0;0 0 1];
Rz2=[0 1 0;-1 0 0;0 0 1];
% 2 possible solutions for rotation matrix R denoted R1 and R2
R1=U*Rz1'*V';
R2=U*Rz2'*V';
% also 2 possible solutions for transaltion matrix T denoted T1 and T2
T1=U*Rz1*S*U';
T2=U*Rz2*S*U';
% transform T to vector using inverse hat operator
T1=[T1(3,2);T1(1,3);T1(2,1)];
T2=[T2(3,2);T2(1,3);T2(2,1)];

end
