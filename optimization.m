load('opt.mat',"opt_correspondences","opt_P1","opt_T","opt_R","opt_lambda","opt_x2_repro","opt_cam1","opt_cam2","min_error");

% define directory
 d='images/terrace';
 s=dir(fullfile(d,'im*.png'));
 I=cell(1,2);

% load images
for i=1:numel(s)
    f=fullfile(d,s(i).name);
    I{i}=imread(f);
    figure;
    imshow(I{i});
    s(i).data=I{i};
end

n_iterations=10000;
K=[711.499 0 376.135;0 711.499 227.447;0 0 1];

[opt_correspondences,opt_P1,opt_T,opt_R,opt_lambda,opt_x2_repro,opt_cam1,opt_cam2,act_min_error]=optimize_repro_error(I{1},I{2},K,n_iterations);
close all;

if act_min_error<min_error
    save('opt.mat',"opt_correspondences","opt_P1","opt_T","opt_R","opt_lambda","opt_x2_repro","opt_cam1","opt_cam2","min_error");
end