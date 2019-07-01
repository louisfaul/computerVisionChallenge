function [EF] = achtpunktalgorithmus(Korrespondenzen, K)
% Diese Funktion berechnet die Essentielle Matrix oder Fundamentalmatrix
% mittels 8-Punkt-Algorithmus, je nachdem, ob die Kalibrierungsmatrix 'K'
% vorliegt oder nicht

if nargin==1 % one function argument
    % extract x1 and x2 from Korrespondenzen matrix and convert to homogeneous coordinates
    % no need to calibrate the coordinates in x1 and x2
    x1=[Korrespondenzen([1 2],:);ones(1,size(Korrespondenzen,2))];
    x2=[Korrespondenzen([3 4],:);ones(1,size(Korrespondenzen,2))];
    % calculate matrix A
    A=zeros(size(Korrespondenzen,2),9);
    for i=1:size(A,1)
        a=zeros(1,9);
        count=1;
        % Kronecker product
        for j=1:3
            for k=1:3
                a(count)=x1(j,i)*x2(k,i);
                count=count+1;
            end
        end
        % add vector a to matrix A
        A(i,:)=a;
    end
    % compute V with Single Value Decomposition (SVD)
    % we only need V
    [~,~,V]=svd(A);
    
elseif nargin==2 % two function arguments (calibration matrix also given)
    % extract x1 and x2 from Korrespondenzen matrix and convert to homogeneous coordinates
    x1=[Korrespondenzen([1 2],:);ones(1,size(Korrespondenzen,2))];
    x2=[Korrespondenzen([3 4],:);ones(1,size(Korrespondenzen,2))];
    % we need to calibrate the coordinates in x1 and x2 (padded with zeros so that dimensions are appropriate) by dividing with the calibration matrix K
    x1=K\x1;
    x2=K\x2;
    % calculate matrix A
    A=zeros(size(Korrespondenzen,2),9);
    for i=1:size(A,1)
        a=zeros(1,9);
        count=1;
        % Kronecker product
        for j=1:3
            for k=1:3
                a(count)=x1(j,i)*x2(k,i);
                count=count+1;
            end
        end
        % add vector a to matrix A
        A(i,:)=a;
    end
    % compute V with Single Value Decomposition (SVD)
    % we only need V
    [~,~,V]=svd(A);

else
    error('Error: number of allowed function arguments exceeded!');
end

% Schaetzung der Matrizen
% we have V from the SVD, we need to compute G
% G is the unstacked version of G_s, which is the 9.th column of matrix V
G_s=V(:,end);
G=reshape(G_s,3,3);
% G isn't an essential matrix. Further steps need to be performed, in order to compute E
% Projection of G into set of normalized essential matrices:
% 1. calculate SVD of G
% 2. set first singular values to one
% 3. set last singular value to zero
[u,s,v]=svd(G);
% calculate essential matrix E
E=u*diag([1 1 0])*v';
if nargin==1 % only one function argument: output should be the fundamental matrix F
    % Fundamental matrix: keep first two singular values ans set the third to zero
    EF=u*diag([s(1,1) s(2,2) 0])*v';
elseif nargin==2 % two function arguments (K also given): output should be the essential matrix E
    EF=E;
else
    error('Error: number of allowed function arguments exceeded!');
end


end
