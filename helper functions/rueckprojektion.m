function [repro_error, x2_repro] = rueckprojektion(Korrespondenzen, P1, Image2, T, R, K)
% Diese Funktion berechnet den mittleren Rueckprojektionsfehler der
% Weltkooridnaten P1 aus Bild 1 im Cameraframe 2 und stellt die
% korrekten Merkmalskoordinaten sowie die rueckprojezierten grafisch dar.

% homogeneous coordinates x2
x2=[Korrespondenzen([3 4],:);ones(1,size(Korrespondenzen,2))];
% homogeneous coordinates P1
P1=[P1;ones(1,size(Korrespondenzen,2))];
x2_repro=K*[eye(3) [0;0;0]]*[R T;0 0 0 1]*P1;
% normalize with respect to z coordinate
norm=repelem(x2_repro(3,:),3,1);
x2_repro=x2_repro./norm;
% plot
figure;
imshow(Image2);
hold on;
plot(Korrespondenzen(3,:),Korrespondenzen(4,:));
plot(x2_repro(1,:),x2_repro(2,:));
for i=1:size(x2_repro,2)
    text(x2_repro(1,i),x2_repro(2,i),num2str(i));
end
% calculate reproduction error
repro_error=0;
for i=1:size(Korrespondenzen,2)
    dist=sqrt((x2_repro(1,i)-x2(1,i))^2+(x2_repro(2,i)-x2(2,i))^2);
    repro_error=repro_error+dist;
end
% mean
repro_error=repro_error/size(Korrespondenzen,2);

end
