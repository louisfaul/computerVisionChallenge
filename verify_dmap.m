function P=verify_dmap(D,G)
% evaluates the quality of the computed disparity map by computing the PSNR
% of the dmap in comparison to a ground-truth dmap

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

