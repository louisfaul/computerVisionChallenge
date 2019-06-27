%% define directory
 d='images/terrace';
 s=dir(fullfile(d,'im*.png'));
 I=cell(1,2);

%% load images
for i=1:numel(s)
    f=fullfile(d,s(i).name);
    I{i}=imread(f);
    figure;
    imshow(I{i});
    s(i).data=I{i};
end

close all;

%% convert images to grayscale
I{1}=rgb_to_gray(I{1});
I{2}=rgb_to_gray(I{2});

%% Harris feature-detection
features_image1=harris_detektor(I{1},'segment_length',9,'k',0.05,'min_dist',40,'N',50,'do_plot',false);
features_image2=harris_detektor(I{2},'segment_length',9,'k',0.05,'min_dist',40,'N',50,'do_plot',false);

%% correspondence search
correspondences=punkt_korrespondenzen(I{1},I{2},features_image1,features_image2,'window_length',25,'min_corr',0.9,'do_plot',false);

%% find robust correspondence pairs using RANSAC
correspondences_robust=F_ransac(correspondences,'p',0.99);

%% show robust correspondence pairs
figure;
imshow(I{1});
hold on;
imshow(I{2});
alpha(0.5);
for i=1:size(correspondences_robust,2)
    plot(correspondences_robust(1,i),correspondences_robust(2,i),'r.'); % plot first point in the column
    plot(correspondences_robust(3,i),correspondences_robust(4,i),'b.'); % plot second point in the column
    plot([correspondences_robust(1,i) correspondences_robust(3,i)],[correspondences_robust(2,i) correspondences_robust(4,i)]); % connect them with a line
end

%% compute essential matrix
K=[711.499 0 376.135;0 711.499 227.447;0 0 1];
E=achtpunktalgorithmus(correspondences_robust,K);

%% compute T1,T2,R1 and R2 from essential matrix E
[T1,R1,T2,R2,~,~]=TR_aus_E(E);
