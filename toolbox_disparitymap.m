%% Matlab built-in disparity map function 
% computes the disparity map for a pair of stereo images 

% % define directory
% d='terrace';
% s=dir(fullfile(d,'im*.png'));
% I=cell(1,2);
% 
% % load images
% for i=1:numel(s)
%     f=fullfile(d,s(i).name);
%     I{i}=imread(f);
%     figure;
%     imshow(I{i});
%     s(i).data=I{i};
% end
% 
% close all;

[D,R,T]=disparity_map('terrace',true);

