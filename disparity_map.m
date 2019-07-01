function [D,R,T]=disparity_map(scene_path)
% This function receives the path to a scene folder and calculates the
% disparity map of the included stereo image pair. Also, the Euclidean
% motion is returned as Rotation R and Translation T.
    
    % input parser
    p=inputParser;
    addRequired(p,'scene_path',@(x) validateattributes(x,{'char'},{'nonempty'}));
    parse(p,scene_path)

    s=dir(fullfile(scene_path,'im*.png'));
    I=cell(numel(s),1);

    % load images
    for i=1:numel(s)
        f=fullfile(scene_path,s(i).name);
        I{i}=imread(f);
        s(i).data=I{i};
    end

    % make sure loaded images are grayscale
    for i=1:numel(s)
        I{i}=rgb_to_gray(I{i});
    end   
    
    % read variables from calibration text file
    K1=textscan(strcat(scene_path,'/calib.txt'),'cam0=[%f %f %f; %f %f %f; %f %f %f]');
    
    % Harris feature-detection
    features_image1=harris_detektor(I{1},'segment_length',9,'k',0.05,'min_dist',40,'N',50,'do_plot',false);
    features_image2=harris_detektor(I{2},'segment_length',9,'k',0.05,'min_dist',40,'N',50,'do_plot',false);
    
    % correspondence search
    correspondences=punkt_korrespondenzen(I{1},I{2},features_image1,features_image2,'window_length',25,'min_corr',0.9,'do_plot',false);
    
    % find robust correspondence pairs using RANSAC
    correspondences_robust=F_ransac(correspondences,'p',0.99);
    
    % compute essential matrix
    E=achtpunktalgorithmus(correspondences_robust,K);
    
    % compute T1,T2,R1 and R2 from essential matrix E
    [T1,R1,T2,R2,~,~]=TR_aus_E(E);
    
    % reconstruction
    [T,R,~,~,~,~]=rekonstruktion(T1,T2,R1,R2,correspondences,K);
    
    % projection
%   [repro_error,x2_repro]=rueckprojektion(correspondences,P1,I{2},T,R,K);

    D=0;


end

