%% load variables
load('opt.mat'); 

disp(opt_R);
disp(opt_T);

disp(min_error);

% camC1
opt_cam1=[-0.2 0.2 0.2 -0.2;0.2 0.2 -0.2 -0.2;1 1 1 1];
% camC2 after rotation R and translation T
opt_cam2=zeros(3,4);
for i=1:size(opt_cam1,2)
    opt_cam2(:,i)=opt_R'*(opt_cam1(:,i)-opt_T);
end

% plot world coordinates P1 using scatter3() function
scatter3(opt_P1(3,:),opt_P1(1,:),opt_P1(2,:));
% for i=1:size(P1,2)
%     text(P1(3,i),P1(1,i),P1(2,i),num2str(i));
% end

hold on;
% cameraframe 1 in blue
plot3([opt_cam1(3,1),opt_cam1(3,2),opt_cam1(3,3),opt_cam1(3,4),opt_cam1(3,1)],[opt_cam1(1,1),opt_cam1(1,2),opt_cam1(1,3),opt_cam1(1,4),opt_cam1(1,1)],[opt_cam1(2,1),opt_cam1(2,2),opt_cam1(2,3),opt_cam1(2,4),opt_cam1(2,1)],'b');
% cameraframe 2 in red
plot3([opt_cam2(3,1),opt_cam2(3,2),opt_cam2(3,3),opt_cam2(3,4),opt_cam2(3,1)],[opt_cam2(1,1),opt_cam2(1,2),opt_cam2(1,3),opt_cam2(1,4),opt_cam2(1,1)],[opt_cam2(2,1),opt_cam2(2,2),opt_cam2(2,3),opt_cam2(2,4),opt_cam2(2,1)],'r');
campos([0,0,0]);

% label axis
xlabel('X');
ylabel('Y');
zlabel('Z');
% activate grid
grid on;