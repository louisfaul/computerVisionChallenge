function P=verify_dmap(D,G)
% This function calculates the PSNR of a given disparity map and the ground
% truth. The value range of both is normalized to [0,255].

% input parser
p=inputParser;
addRequired(p,'D',@(x) isnumeric(x));
addRequired(p,'G',@(x) isnumeric(x));
parse(p,D,G);

if size(p.Results.D)~=size(p.Results.G)
    error('Error: disparity map D and ground truth G must be of same size!');
end

P=0;
end

