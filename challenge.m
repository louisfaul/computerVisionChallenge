%% Computer Vision Challenge 2019

% Group number:
group_number=12;

% Group members:
members={'Ines Boussarsar','Lobna Boussarsar','Louis Faul','Louis Somme','Mohamed Bourguiba'};

% Email-Address (from Moodle!):
mail={'','','','','ga78ver@mytum.de'};

%% Start timer here
tic;

%% Disparity Map
% Specify path to scene folder containing img0 img1 and calib
scene_path='images/terrace';
 
% Calculate disparity map and Euclidean motion
[D,R,T]=disparity_map(scene_path);

%% Validation
% Specify path to ground truth disparity map
gt_path='images/terrace/disp0.pfm';

% Load the ground truth
G=load(gt_path);

% Estimate the quality of the calculated disparity map
p=validate_dmap(D,G);

%% Stop timer here
elapsed_time=toc;