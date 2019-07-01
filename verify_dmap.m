function P=verify_dmap(D,G)
% This function calculates the PSNR of a given disparity map and the ground
% truth. The value range of both is normalized to [0,255].

% input parser
p=inputParser;
addRequired(p,'D',@(x) isnumeric(x));
addRequired(p,'G',@(x) isnumeric(x));
parse(p,D,G);

% check if input images D and G are of the same size
if size(p.Results.D)~=size(p.Results.G)
    error('Error: disparity map D and ground truth G must be of same size!');
end

% normalize value range to [0,255]
D_min=double(min(min(D)));
D_max=double(max(max(D)));
G_min=double(min(min(D)));
G_max=double(max(max(G)));
D=uint8(255.*((double(D)-D_min))./(D_max-D_min));
G=uint8(255.*((double(G)-G_min))./(G_max-G_min));

% compute the peak signal-to-noise ratio in decibels between disparity map
% D and ground-truth G. The higher the PSNR, the better the quality of the
% computed disparity map D 

% define maximum fluctuation R (255 for uint8 images)
R=255.;

% calculate mean-square error MSE between input images D and G
% init MSE
% % MSE=0;
% % for m=1:size(D,1)
% %     for n=1:size(D,2)
% %         MSE=MSE+double((D(m,n)-G(m,n))^2);
% %     end
% % end

% matrix computation
MSE=sum(sum((D-G).^2));
MSE=double(MSE/(size(D,1)*size(D,2)));

% calculte the PSNR p in dB
P=10*log10(R^2/MSE);

disp(['Peak Signal-to-Noise Ratio: ',num2str(P),' dB .']);

end

