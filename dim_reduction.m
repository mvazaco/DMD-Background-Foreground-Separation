clear all; close all; clc

video = importdata("D:\Datasets\SciML\PROJECT\matrix\highway.mat");
X     = importdata("D:\Datasets\SciML\PROJECT\matrix\highway_columnated.mat");

% video = importdata("D:\Datasets\SciML\PROJECT\matrix\monte_carlo_low.mat");
% X     = importdata("D:\Datasets\SciML\PROJECT\matrix\monte_carlo_low_columnated.mat");

% video = importdata("D:\Datasets\SciML\PROJECT\matrix\PETS2006.mat");
% X     = importdata("D:\Datasets\SciML\PROJECT\matrix\PETS2006_columnated.mat");

% video = importdata("D:\Datasets\SciML\PROJECT\matrix\pedestrians.mat");
% X     = importdata("D:\Datasets\SciML\PROJECT\matrix\pedestrians_columnated.mat");

% % Static object/ Slow movement
% video = importdata("D:\Datasets\SciML\PROJECT\matrix\office.mat");
% X     = importdata("D:\Datasets\SciML\PROJECT\matrix\office_columnated.mat");

n_frames = size(X,2);
im_h = size(video, 1);
im_w = size(video, 2);

%% Break video stream into segments

segment_frames = 30;
no_segments = floor(size(X,2)/segment_frames);

r_values = [1, 10, segment_frames-1];
threshold = 0.5;

figure;
subplottight(1,4,1), imshow(mat2gray(reshape(X(:,275), [im_h, im_w])), 'border', 'tight');
for ell = 1:length(r_values)
    Full_X_LowRank_DMD = zeros(size(X,1),size(X,2));
    Full_X_Sparse_DMD  = zeros(size(X,1),size(X,2));
    for i = 0:no_segments-1
        if i ~= no_segments
            X_segmented = X(:, 1+i*segment_frames:(i+1)*segment_frames);
            [X_DMD, X_LowRank_DMD, X_Sparse_DMD, omega_bg] = video_DMD(X_segmented, threshold, r_values(ell));
            Full_X_LowRank_DMD(:,1+i*segment_frames:(i+1)*segment_frames) = X_LowRank_DMD;
            Full_X_Sparse_DMD (:,1+i*segment_frames:(i+1)*segment_frames) = X_Sparse_DMD;
        else
            X_segmented = X(:, i*segment_frames:end);
            [X_DMD, X_LowRank_DMD, X_Sparse_DMD, omega_bg] = video_DMD(X_segmented, threshold, r_values(ell));
            Full_X_LowRank_DMD(:,1+i*segment_frames:end) = X_LowRank_DMD;
            Full_X_Sparse_DMD (:,1+i*segment_frames:end) = X_Sparse_DMD;
        end
    end
    vid_filter = Full_X_Sparse_DMD>0.2;
    subplottight(1,4,1+ell), imshow(reshape(vid_filter(:,275), [im_h, im_w]), 'border', 'tight');
end

