function [D,R,T]=disparity_map(scene_path,varargin)
    % input parser
    p=inputParser;
    addRequired(p,'scene_path',@(x) validateattributes(x,{'char'},{'nonempty'}));
    addOptional(p,'do_plot',1,@(x) islogical(x));
    parse(p,scene_path,varargin{:});
    do_plot=p.Results.do_plot;

    s=dir(fullfile(scene_path,'im*.png'));
    I=cell(numel(s),1);

    % load images
    for i=1:numel(s)
        f=fullfile(scene_path,s(i).name);
        I{i}=imread(f);
        s(i).data=I{i};
    end

    % make sure loaded images are grayscale
    for i=1:numel(s)
        I{i}=rgb_to_gray(I{i});
        if do_plot
            figure;
            imshow(I{i});
        end
    end   

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

    D=0;
    R=0;
    T=0;

end

