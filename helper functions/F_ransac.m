function [Korrespondenzen_robust] = F_ransac(Korrespondenzen, varargin)
% Diese Funktion implementiert den RANSAC-Algorithmus zur Bestimmung von
% robusten Korrespondenzpunktpaaren

%% input parser
p=inputParser;
% default parameters
defaultEpsilon=0.5;
defaultP=0.5;
defaultTolerance=0.01;
% define validation functions
checkEpsilon=@(x) isnumeric(x) && (x>0) && (x<1);
checkP=@(x) isnumeric(x) && (x>0) && (x<1);
checkTolerance=@(x) isnumeric(x);
% add inputs
addRequired(p,'Korrespondenzen');
addParameter(p,'epsilon',defaultEpsilon,checkEpsilon);
addParameter(p,'P',defaultP,checkP);
addParameter(p,'tolerance',defaultTolerance,checkTolerance);
% parse inputs
parse(p,Korrespondenzen,varargin{:});
x1_pixel=[Korrespondenzen([1 2],:);ones(1,size(Korrespondenzen,2))];
x2_pixel=[Korrespondenzen([3 4],:);ones(1,size(Korrespondenzen,2))];

epsilon=p.Results.epsilon;
P=p.Results.P;
tolerance=p.Results.tolerance;

%% RANSAC Algorithmus Vorbereitung
% number of required points
k=8;
% iteration number
s=log(1-P)/log(1-(1-epsilon)^k);
% largest set size
largest_set_size=0;
% largest set distance
largest_set_dist=inf;
% buffer for fundamental matrix
largest_set_F=zeros(3,3);

%% RANSAC Algorithmus
% number of correspondence pairs in the data
number_pair=size(Korrespondenzen,2);
% set counter
i=1;
% while counter i is less than or equal number of iteration s, perform following steps
while i<=s
    % 1. estimate fundamental matrix F for k randomly chosen correspondence pairs using the 8-point algorithm
    %random_pair=datasample(Korrespondenzen,k,2,'Replace',false);
    % first, create vector of random non-repeatable indices within range [1 number_pair]
    random_idx=sort(randperm(number_pair,k),'ascend');
    % then perform 8-point algorithm
    F_random=achtpunktalgorithmus(Korrespondenzen(:,random_idx));
    % extract x1 and x2 and convert them to homogeneous coordinates
    x1_hom=[Korrespondenzen([1 2],:);ones(1,number_pair)];
    x2_hom=[Korrespondenzen([3 4],:);ones(1,number_pair)];
    F=achtpunktalgorithmus(Korrespondenzen);
    % 2. calculate Sampson distance for all correspondence pairs
    sampson=sampson_dist(F,x1_hom,x2_hom);
    % opt. calculate sampson distance for randomly chosen pairs
    sampson_random=sampson_dist(F_random,x1_hom,x2_hom);
    % 3. include each correspondence pair in the Consensus Set, whose sampson distance is less than tolerance
    consensus_set_idx=find(sampson<tolerance);
    % 4. determine actual consensus-set size and actual sum of sampson distances
    act_size=numel(consensus_set_idx);
    act_dist=sum(sampson(consensus_set_idx));
    % 5. compare these values with those of the previous consensus set
    if (act_size>largest_set_size) || ((act_size==largest_set_size) && (act_dist<largest_set_dist))
        % if one of the above conditions is fulfilled, set largest set size and absolute distance to the actual
        largest_set_size=act_size;
        largest_set_dist=act_dist;
        % store fundamental matrix F in largest_set_F
        largest_set_F=F_random;
        % 6. store information for largest_set_size
        largest_set_info=sampson_random<tolerance;
    end
    % increment counter at each iteration
    i=i+1;
end

% compute Korrespondenzen_robust
Korrespondenzen_robust=Korrespondenzen(:,largest_set_info);

end
