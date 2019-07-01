function [opt_correspondences,opt_P1,opt_T,opt_R,opt_lambda,opt_x2_repro,opt_cam1,opt_cam2,min_error]=optimize_repro_error(I1,I2,K,n_iterations)
% convert images to grayscale
I1=rgb_to_gray(I1);
I2=rgb_to_gray(I2);

min_error=9999.;

for i=1:n_iterations
    % Harris feature-detection
    features_image1=harris_detektor(I1,'segment_length',9,'k',0.05,'min_dist',40,'N',50,'do_plot',false);
    features_image2=harris_detektor(I2,'segment_length',9,'k',0.05,'min_dist',40,'N',50,'do_plot',false);
    
    % correspondence search
    current_correspondences=punkt_korrespondenzen(I1,I2,features_image1,features_image2,'window_length',25,'min_corr',0.9,'do_plot',false);
    
    % find robust correspondence pairs using RANSAC
    current_correspondences_robust=F_ransac(current_correspondences,'p',0.99);
    
    % compute essential matrix
    current_E=achtpunktalgorithmus(current_correspondences_robust,K);
    
    % compute T1,T2,R1 and R2 from essential matrix E
    [T1,R1,T2,R2,~,~]=TR_aus_E(current_E);
    
    % reconstruction
    [current_T,current_R,current_lambda,current_P1,current_cam1,current_cam2]=rekonstruktion(T1,T2,R1,R2,current_correspondences,K);
    
    % projection
    [current_repro_error,current_x2_repro]=rueckprojektion(current_correspondences,current_P1,I2,current_T,current_R,K);
    
    if current_repro_error<min_error
        min_error=current_repro_error;
        opt_correspondences=current_correspondences;
        opt_P1=current_P1;
        opt_T=current_T;
        opt_R=current_R;
        opt_x2_repro=current_x2_repro;
        opt_lambda=current_lambda;
        opt_cam1=current_cam1;
        opt_cam2=current_cam2;
    end
    
    if abs(min_error-current_repro_error)/min_error<=.01
        break;
    end
end
 
end