% define directory
 d='images/terrace';
 s=dir(fullfile(d,'im*.png'));
 I=cell(1,2);

% load images
for i=1:numel(s)
    f=fullfile(d,s(i).name);
    I{i}=imread(f);
    s(i).data=I{i};
end

% convert images to grayscale
I{1}=rgb_to_gray(I{1});
I{2}=rgb_to_gray(I{2});

% use the built-in disparity map function with semi-global matching
% method
disparitymap1=disparitySGM(I{1},I{2});
% use the built-in disparity map function with block matching method
disparitymap2=disparityBM(I{1},I{2});

% disparity range of graysacle images of width N must be integers in
% the range -N...N and the length of this interval must be divisible by
% 16
disparity_range=[0 32];

% display disparity map
subplot(2,1,1);
imshow(disparitymap1,disparity_range);
title('Disparity Map using Matlab''s built-in function (SGM)');
colormap jet;
colorbar;

subplot(2,1,2);
imshow(disparitymap2,disparity_range);
title('Disparity Map using Matlab''s built-in function (BM)');
colormap jet;
colorbar;