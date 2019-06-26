function Korrespondenzen = punkt_korrespondenzen(I1,I2,Mpt1,Mpt2,varargin)
% In dieser Funktion sollen die extrahierten Merkmalspunkte aus einer
% Stereo-Aufnahme mittels NCC verglichen werden um Korrespondenzpunktpaare
% zu ermitteln.

%% Input parser
% create an input parser
p=inputParser;
% declare default values
defaultWindowLength=25;
defaultMinCorr=0.95;
defaultDoPlot=false;
% define verification functions
checkWindowLength=@(x) isnumeric(x) && (mod(x,2)~=0) && (x>1);
checkMinCorr=@(x) isnumeric(x) && (x>0) && (x<1);
checkDoPlot=@(x) islogical(x);
% add variable to the input parser
addRequired(p,'I1');
addRequired(p,'I2');
addRequired(p,'Mpt1');
addRequired(p,'Mpt2');
addParameter(p,'window_length',defaultWindowLength,checkWindowLength);
addParameter(p,'min_corr',defaultMinCorr,checkMinCorr);
addParameter(p,'do_plot',defaultDoPlot,checkDoPlot);
% parse inputs
parse(p,I1,I2,Mpt1,Mpt2,varargin{:});

window_length=p.Results.window_length;
min_corr=p.Results.min_corr;
do_plot=p.Results.do_plot;

%% Merkmalsvorbereitung
figure(1);
imshow(I1);
hold on;
for p=1:size(Mpt1,2)
    plot(Mpt1(1,p),Mpt1(2,p),'bo'); % features in Mpt1 before removal of border features
end
figure(2);
imshow(I2);
hold on;
for p=1:size(Mpt2,2)
    plot(Mpt2(1,p),Mpt2(2,p),'bo'); % features in Mpt2 before removal of border features
end

% length and width of image 1
l1=size(I1,1);
w1=size(I1,2);
% length and width of image 2
l2=size(I2,1);
w2=size(I2,2);
pts1=[];
pts2=[];
% border
border=window_length/2;
% Mpt1
for p=1:size(Mpt1,2) % number of features in Mpt1: 1 column=1 feature
    % extract coordinates of current point
    x=Mpt1(1,p);
    y=Mpt1(2,p);
    if (x>=ceil(border)) & (x<=w1-floor(border)) & (y>=ceil(border)) & (y<=l1-floor(border))
        % if condition is fulfilled: point lies in the image center add it to pts1
        pts1=horzcat(pts1,[x;y]);
    else
        continue;
    end
end

% Mpt2
for p=1:size(Mpt2,2) % number of features in Mpt2: 1 column=1 feature
    % extract coordinates of current point
    x=Mpt2(1,p);
    y=Mpt2(2,p);
    if (x>=ceil(border)) & (x<=w2-floor(border)) & (y>=ceil(border)) & (y<=l2-floor(border))
        % if condition is fulfilled: point lies in the image center add it to pts2
        pts2=horzcat(pts2,[x;y]);
    else
        continue;
    end
end

Mpt1=pts1;
Mpt2=pts2;
% number of points in pts1 and pts2
no_pts1=size(Mpt1,2);
no_pts2=size(Mpt2,2);

%% optional: for visualization purposes: after features processing
% figure(1);
% for p=1:size(Mpt1,2)
% plot(Mpt1(1,p),Mpt1(2,p),'rs'); % features in Mpt2 after removal of border features
% end
% hold off;
% figure(2);
% for p=1:size(Mpt2,2)
% plot(Mpt2(1,p),Mpt2(2,p),'rs'); % features in Mpt1 after removal of border features
% end
% hold off;

%% Normierung
% check dimensions of Mpt1 and Mpt2
size(Mpt1);
size(Mpt2);
% initialize Mat_feat_1 and Mat_feat_2 with zeros
% dimensions: rows number equals number of elements in the normalized window
% columns number equals number of features in Mpt1/2 as shown in the example of the assignment
Mat_feat_1=zeros(window_length^2,size(Mpt1,2));
Mat_feat_2=zeros(window_length^2,size(Mpt2,2)); % dimensions correct:approved by test bench
translation=-floor(window_length/2):floor(window_length/2);

for i=1:size(Mpt1,2)
    % determine window coordinates around each feature point
    % add indexes of the window elements. for window_length=3 we have vector -1:1, for 5: -2:2, etc.
    x=Mpt1(1,i)+translation;
    y=Mpt1(2,i)+translation;
    % take image values for these coordinates as window
    window=double(I1(y,x));
    % normalize the values with respect to the above formula: substract mean and divide by standard deviation
    % first, compute mean and standard deviation of the elements in the window
    mu=mean(window(:));
    sigma=std(window(:));
    % convert the matrix window in a column vetor and add it to mat_feat_1
    Mat_feat_1(:,i)=(window(:)-mu)/sigma;
end

for j=1:size(Mpt2,2)
    % determine window coordinates around each feature point
    % add indexes of the window elements. for window_length=3 we have vector -1:1, for 5: -2:2, etc.
    x=Mpt2(1,j)+translation;
    y=Mpt2(2,j)+translation;
    % take image values for these coordinates as window
    window=double(I2(y,x));
    % normalize the values with respect to the above formula: substract mean and divide by standard deviation
    % first, compute mean and standard deviation of the elements in the window
    mu=mean(window(:));
    sigma=std(window(:));
    % convert the matrix window in a column vetor and add it to mat_feat_2
    Mat_feat_2(:,j)=(window(:)-mu)/sigma;
end

%% NCC Brechnung
% N
N=window_length^2;
% NCC matrix
NCC=1/(N-1)*Mat_feat_2'*Mat_feat_1;
% set all values less than minimum correaltion threshold in the NCC matrix to zero
NCC(NCC<min_corr)=0;
% sort the correspondence values in the NCC matrix in a descending order
[sorted_value,sorted_index]=sort(NCC(:),'descend');
% eliminate the indices corresponding to the zero values in the NCC matrix
sorted_index(sorted_value==0)=[];

%% Korrespondenz
% initialize Korrespondenzen matrix
% k number of relevant features
K=min(no_pts1,no_pts2);
Korrespondenzen=zeros(4,K);
counter=1;
for i=1:numel(sorted_index)
    idx=sorted_index(i);
    % check if corresponding correspondence value in NCC matrix is still non zero
    if NCC(idx)==0
        continue;
    else
        % extract xy-coordinates using ind2sub
        [idx2,idx1]=ind2sub(size(NCC),idx);
        % set corresponding column to 0 to avoid allocating another correspondence point from image 2 to current point from image 1
        NCC(:,idx1)=0;
        % add points over each other starting by point from image 1 to the Korrespondenzen matrix
        Korrespondenzen(:,counter)=[Mpt1(:,idx1);Mpt2(:,idx2)];
        % increment counter
        counter=counter+1;
    end
end

Korrespondenzen=Korrespondenzen(:,1:counter-1);

%% Zeige die Korrespondenzpunktpaare an
if do_plot==true
    imshow(I1);
    hold on;
    imshow(I2);
    alpha(0.5);
    for i=1:size(Korrespondenzen,2)
        plot(Korrespondenzen(1,i),Korrespondenzen(2,i),'r.'); % plot first point in the column
        plot(Korrespondenzen(3,i),Korrespondenzen(4,i),'b.'); % plot second point in the column
        plot([Korrespondenzen(1,i) Korrespondenzen(3,i)],[Korrespondenzen(2,i) Korrespondenzen(4,i)]); % connect them with a line
    end
end

end
