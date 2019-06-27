function merkmale = harris_detektor(input_image, varargin)
% In dieser Funktion soll der Harris-Detektor implementiert werden, der
% Merkmalspunkte aus dem Bild extrahiert

%% Input parser
p=inputParser;
% default parameters
defaultSegmentLength=15;
defaultK=0.05;
defaultTau=10^6;
defaultDoPlot=false;
defaultMinDist=20;
defaultN=5;
% define validation functions
checkSegmentLength=@(x) isnumeric(x) && isscalar(x) && (x>1) && (mod(x,2)~=0);
checkK=@(x) isnumeric(x) && (x>=0) && (x<=1);
checkTau=@(x) isnumeric(x) && (x>0);
checkDoPlot=@(x) islogical(x);
checkMinDist=@(x) isnumeric(x) && (x>=1);
checkN=@(x) isnumeric(x) && (x>=1);
% add inputs
addRequired(p,'input_image');
addParameter(p,'segment_length',defaultSegmentLength,checkSegmentLength);
addParameter(p,'k',defaultK,checkK);
addParameter(p,'tau',defaultTau,checkTau);
addParameter(p,'do_plot',defaultDoPlot,checkDoPlot);
addParameter(p,'min_dist',defaultMinDist,checkMinDist);
addParameter(p,'tile_size',[200 200],@isnumeric);
addParameter(p,'N',defaultN,checkN);
% parse inputs
parse(p,input_image,varargin{:});

min_dist=p.Results.min_dist;
tile_size=p.Results.tile_size;
N=p.Results.N;
segment_length=p.Results.segment_length;
tau=p.Results.tau;
k=p.Results.k;
do_plot=p.Results.do_plot;

if numel(tile_size)==1
    tile_size=[tile_size,tile_size];
end


%% Vorbereitung zur Feature Detektion
% Pruefe ob es sich um ein Grauwertbild handelt
[~,~,nChannels]=size(input_image);
if nChannels~=1
    error('Image format has to be NxMx1');
end
input_image=double(input_image);
% Approximation des Bildgradienten
[Ix,Iy]=sobel_xy(input_image);
% Gewichtung
% we use a gaussian weighted vector with standar deviation proportional to segment_length (segment_length/10: small sigma in order to emphasize the central pixel)
w=fspecial('gaussian',[segment_length,1],segment_length/10);
% Harris Matrix G
% G11 (without for-loops)
G11=conv2(w,w,Ix.^2,'same');
% G12
G12=conv2(w,w,Ix.*Iy,'same');
% G22
G22=conv2(w,w,Iy.^2,'same');

%% Merkmalsextraktion ueber die Harrismessung
% Harrismessung
H=(G11.*G22-G12.^2)-k*((G11+G22).^2);
% Behandlung von Merkmalen am Rand des Bildes
rand=zeros(size(H));
c=ceil(segment_length/2);
rand((c+1):(size(H,1)-c),(c+1):(size(H,2)-c))=1;
% Berchnung von corners
corners=H.*rand;
corners(corners<=tau)=0;
corners=double(corners);
[r,c]=find(corners);
% kombinieren von den Vektoren r und c um merkmale zu extrahieren
merkmal=[c r]';
 
% size(merkmal)
% imagesc(input_image)
% hold on;
% plot(merkmal(1,min(5,size(merkmal,2))),merkmal(2,min(5,size(merkmal,2))),'ro');
% ylim([0,350]);
% xlim([0,10]);

%% Merkmalsvorbereitung
horz_nullrand=horzcat(zeros(size(corners,1),min_dist),corners,zeros(size(corners,1),min_dist));
vert_nullrand=vertcat(zeros(min_dist,2*min_dist+size(corners,2)),horz_nullrand,zeros(min_dist,2*min_dist+size(corners,2)));
corners=vert_nullrand;
[sorted_values,sorted_index]=sort(corners(:),'descend');
sorted_index(sorted_values==0)=[];

%% Akkumulatorfeld
% create AKKA matrix and initialize it with zeros
% the dimensions of the AKKA field are dependent of the the dimesions of the variable tile_size
% number of rows: height of input image divided by tile_size height
nHeight=ceil(size(input_image,1)/tile_size(1));
% number of columns: width of input image divided by tile_size width
nWidth=ceil(size(input_image,2)/tile_size(2));
AKKA=zeros(nHeight,nWidth);
% create merkmale matrix and initialize it with zeros
% its dimensions are dependent of the maximal number of features N per tile (defined by the user) and the number of non-zero features in sorted index
nFeatures=numel(sorted_index);
% number of rows:2
% number of columns: minimum between number of non zero features nFeatures and the maximal number of features in the AKKA matrix: number of array elements in AKKA multiplied by N
merkmaleD=zeros(2,min(nFeatures,numel(AKKA)*N));

%% Merkmalsbestimmung mit Mindestabstand und Maximalzahl pro Kachel
% Visualize corners and tiles
% imshow(corners);
% hold on;
% draw horizontal lines over corners at distant intervals (height of tile)
% for i=1:tile_size(1):size(corners,2)
%     m=[i i];
%     n=[1 size(corners,1)];
%     plot(m,n,'r');
% end
% % draw vertical lines over corners at distant intervals (width of tile)
% for j=1:tile_size(2):size(corners,1)
%     m=[1 size(corners,2)];
%     n=[j j];
%     plot(m,n,'r');
% end
% go through the indices of the features stored in the sorted_index vector
counter=1;
tic;
for p=1:numel(sorted_index)
    % extract index of the current point
    idx=sorted_index(p);
    % only process current point if its value in the corners matrix is non-zero else proceed to the next one in sorted_index
    if corners(idx)==0
        continue;
    else
        % convert linear index into subscripts i.e. xy-coordinates in the corners matrix
        [r,c]=ind2sub(size(corners),idx);
        % determine the tile containing the current feature point and increment its value in the AKKA field
        x=floor((r-min_dist-1)/tile_size(1))+1;
        y=floor((c-min_dist-1)/tile_size(2))+1;
        % only increment if corresponding AKKA field's value is less than maximum number of features per tile N
        if AKKA(x,y)<N
            AKKA(x,y)=AKKA(x,y)+1;
            % store the feature in the merkmale matrix
            merkmale(:,counter)=[c-min_dist;r-min_dist];
            % plot it in the corners matrix
            %plot(c-min_dist,r-min_dist,'bo','LineWidth',2);
            % only increment counter if feature point is to be stored in the merkmale matrix
            counter=counter+1;
        elseif AKKA(x,y)==N % N has reached maximum allowed value per tile
            % set all others features in this tile to zero
            corners((x-1)*tile_size(1)+min_dist+1:x*tile_size(1)+min_dist,(y-1)*tile_size+min_dist+1:y*tile_size(2)+min_dist)=0;
        end
        % to avoid processing that further feature points whose distances to the current point are less than min_dist
        % set their values in the corners matrix to zero by multipling the surrounding region with the cake matrix of the same dimensions
        corners(r-min_dist:r+min_dist,c-min_dist:c+min_dist)=corners(r-min_dist:r+min_dist,c-min_dist:c+min_dist).*cake(min_dist);
    end
end

%hold off;
merkmale=merkmale(:,1:counter-1);
t=toc;
%disp([num2str(N),' strongest feature points per tile identified in: ',num2str(t),' seconds']);

% display AKKA field and compare number of feature points per tile visually with the help of the gridded corners matrix
% AKKA

%% Plot
if do_plot
    image(input_image);
    hold on;
    plot(merkmale(1,:),merkmale(2,:),'o');
end

end
