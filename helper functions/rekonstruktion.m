function [T, R, lambda, P1, camC1, camC2] = rekonstruktion(T1, T2, R1, R2, Korrespondenzen, K)
%% Preparation
% create two cell arrays T and R
T_cell={T1,T2,T1,T2};
R_cell={R1,R1,R2,R2};
% define x1 and x2
x1=[Korrespondenzen([1 2],:);ones(1,size(Korrespondenzen,2))];
x2=[Korrespondenzen([3 4],:);ones(1,size(Korrespondenzen,2))];
% calibrate coordinates using claibration matrix K
x1=K\x1;
x2=K\x2;
% initialize cell array d_cell
d_cell=cell(1,4);
d_cell{1}=zeros(size(Korrespondenzen,2),2);
d_cell{2}=zeros(size(Korrespondenzen,2),2);
d_cell{3}=zeros(size(Korrespondenzen,2),2);
d_cell{4}=zeros(size(Korrespondenzen,2),2);

% iterate through the possible combinations
for i=1:4
    %% 1. Matrix M1 and M2
    M1_l=[];
    M1_r=[];
    M2_l=[];
    M2_r=[];
    for j=1:size(Korrespondenzen,2)
        % construct left part of matrix M1
        M1_l=blkdiag(M1_l,hat(x2(:,j))*R_cell{i}*x1(:,j));
        % construct right part of matrix M1 (last column)
        M1_r=vertcat(M1_r,hat(x2(:,j))*T_cell{i});
        % construct left part of matrix M2
        M2_l=blkdiag(M2_l,hat(x1(:,j))*R_cell{i}'*x2(:,j));
        % construct right part of matrix M2 (last column)
        M2_r=vertcat(M2_r,-(hat(x1(:,j))*R_cell{i}'*T_cell{i}));
    end
    % construct matrix M1
    M1=[M1_l,M1_r];
    % construct matrix M2 (dimensions 96x32)
    M2=[M2_l,M2_r];
    %% 2. calculate solutions for equation systems using SVD (last column of vector v)
    [~,~,v1]=svd(M1);
    [~,~,v2]=svd(M2);
    % d1 and d2 of dimensions 33x1
    d1=v1(:,end);
    d2=v2(:,end);
    % normalization with respect to last element teta so that teta=1
    d1=d1/d1(end);
    d2=d2/d2(end);
    %% 3. copy them into d_cell
    d_cell{i}=[d1(1:end-1) d2(1:end-1)];
end

%% 4. select the combination R, T with the most positive lambdas
max_pos_alpha=length(find(d_cell{1}>0));
T=T_cell{1};
R=R_cell{1};
lambda=d_cell{1};
plausible_comb=1;
for i=2:4
    num_pos_alpha_current=length(find(d_cell{i}>0));
    % if current d_cell matrix has more positive alphas than d_cell{1}
    if num_pos_alpha_current>max_pos_alpha
        T=T_cell{i};
        R=R_cell{i};
        lambda=d_cell{i};
        max_pos_alpha=num_pos_alpha_current;
        plausible_comb=i;
    end
end

%disp([num2str(plausible_comb),' . combination is the geometrically plausible combination.']);

% calculate world coordinates P1
lambdas=repelem(lambda(:,1)',3,1);
P1=lambdas.*x1;
% camC1
camC1=[-0.2 0.2 0.2 -0.2;0.2 0.2 -0.2 -0.2;1 1 1 1];
% camC2 after rotation R and translation T
camC2=zeros(3,4);
for i=1:size(camC1,2)
    camC2(:,i)=R'*(camC1(:,i)-T);
end

end