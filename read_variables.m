function vars=read_variables(calib_path)
% This function receives the path to a calibration file and extracts the
% following variables:
% 
% cam0,1:        camera matrices for the rectified views, in the form [f 0 cx; 0 f cy; 0 0 1], where
%   f:           focal length in pixels
%   cx, cy:      principal point  (note that cx differs between view 0 and 1)
% 
% doffs:         x-difference of principal points, doffs = cx1 - cx0
% 
% baseline:      camera baseline in mm
% 
% width, height: image size
% 
% ndisp:         a conservative bound on the number of disparity levels;
%                the stereo algorithm MAY utilize this bound and search from d = 0 .. ndisp-1
% 
% isint:         whether the GT disparites only have integer precision (true for the older datasets;
%                in this case submitted floating-point disparities are rounded to ints before evaluating)
% 
% vmin, vmax:    a tight bound on minimum and maximum disparities, used for color visualization;
%                the stereo algorithm MAY NOT utilize this information
% 
% dyavg, dymax:  average and maximum absolute y-disparities, providing an indication of
%                the calibration error present in the imperfect datasets.

    % input parser
    p=inputParser;
    addRequired(p,'calib_path',@(x) validateattributes(x,{'char'},{'nonempty'}));
    parse(p,calib_path)
    
    % open file
    fileID=fopen(calib_path);
    
    % read variables
    K1=textscan(fileID,'cam0=[%f %f %f; %f %f %f; %f %f %f]');
    K2=textscan(fileID,'cam1=[%f %f %f; %f %f %f; %f %f %f]');
    doffs=textscan(fileID,'doffs=%f');
    baseline=textscan(fileID,'baseline=%f');
    width=textscan(fileID,'width=%d');
    height=textscan(fileID,'height=%d');
    ndisp=textscan(fileID,'ndisp=%d');
    
    % close file
    fclose(fileID);
    
    % init varibales cell array
    vars={0,0,0,0,0,0,0};
    
    % camera matrice 1
    vars{1}=cell2num(K1);
    % camera matrice 2
    vars{2}=cell2num(K2);
    % doffs
    vars{3}=doffs{1};
    % baseline
    vars{4}=baseline{1};
    % width
    vars{5}=width{1};
    % height
    vars{6}=height{1};
    % ndisp
    vars{7}=ndisp{1};
    
end

