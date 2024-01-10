clear all; close all; clc

video = importdata("C:\DATASETS\highway.mat");
X     = importdata("C:\DATASETS\highway_columnated.mat");

% video = importdata("C:\DATASETS\badminton.mat");
% X     = importdata("C:\DATASETS\badminton_columnated.mat");

% video = importdata("D:\Datasets\SciML\PROJECT\matrix\busStation.mat");
% X     = importdata("D:\Datasets\SciML\PROJECT\matrix\busStation_columnated.mat");

% video = importdata("D:\Datasets\SciML\PROJECT\matrix\peopleInShade.mat");
% X     = importdata("D:\Datasets\SciML\PROJECT\matrix\peopleInShade_columnated.mat");

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

%% Break video stream into segments
% segment_frames = n_frames;
segment_frames = 100;
no_segments = floor(size(X,2)/segment_frames);

r = segment_frames-1;
threshold = 0.5;
Full_X_LowRank_DMD = zeros(size(X,1),size(X,2));
Full_X_Sparse_DMD  = zeros(size(X,1),size(X,2));
for i = 0:no_segments-1
    if i ~= no_segments
        X_segmented = X(:, 1+i*segment_frames:(i+1)*segment_frames);
        [X_DMD, X_LowRank_DMD, X_Sparse_DMD, omega_bg] = video_DMD(X_segmented, threshold, r);
        Full_X_LowRank_DMD(:,1+i*segment_frames:(i+1)*segment_frames) = X_LowRank_DMD;
        Full_X_Sparse_DMD (:,1+i*segment_frames:(i+1)*segment_frames) = X_Sparse_DMD;
    else
        X_segmented = X(:, i*segment_frames:end);
        [X_DMD, X_LowRank_DMD, X_Sparse_DMD, omega_bg] = video_DMD(X_segmented, threshold, r);
        Full_X_LowRank_DMD(:,1+i*segment_frames:end) = X_LowRank_DMD;
        Full_X_Sparse_DMD (:,1+i*segment_frames:end) = X_Sparse_DMD;
    end
end

%% show reconstructed videos
im_h = size(video, 1);
im_w = size(video, 2);

% % for flow past cylinder
% im_h = n;
% im_w = m;

% k = 10;
% frame = reshape(algo(:,k), [im_h, im_w]) - reshape(X_LowRank(:,k), [im_h, im_w]);
% imshow(mat2gray(frame));

% ORIGINAL
figure;
for i = 1:n_frames
    frame = reshape(X(:,i), [im_h, im_w]);
    imshow(mat2gray(frame));
    title('ORIGINAL');
    drawnow
end

% DMD RECONSTRUCTION
for i = 1:n_frames
    frame = reshape((X_DMD(:,i)), [im_h, im_w]);
    imshow(mat2gray(frame));
    title('DMD RECONSTRUCTION');
    drawnow
end

% BACKGROUND
for i = 1:n_frames
    frame = reshape((X_LowRank_DMD(:,i)), [im_h, im_w]);
    imshow(mat2gray(frame));
    title('X LowRank DMD');
    drawnow
end

% FOREGROUND
vid_filter = Full_X_Sparse_DMD>0.25;
for i = 1:n_frames
%       frame = reshape(Full_X_Sparse_DMD(:,i), [im_h, im_w]);
    frame = reshape(vid_filter(:,i), [im_h, im_w]);
    imshow(mat2gray(frame));
    title('X Sparse DMD');
    drawnow
end

%% show fg filtered video

vid_filter = Full_X_Sparse_DMD>0.1;
% triplicate filter for r,g,b channels
A=cat(3,vid_filter,vid_filter,vid_filter);
% A=cat(3,Full_X_Sparse_DMD,Full_X_Sparse_DMD,Full_X_Sparse_DMD);
A=permute(A,[1 3 2]);
A=reshape(A,[(im_h) (im_w) (3) (n_frames)]);

% filtered video, with BG removed!
f_vid = double(video(:,:,:,1:end)).*double(A);

for i=1:n_frames
    imshow(uint8(f_vid(:,:,:,i)));
    drawnow
end

%% results plotting

vid_filter = Full_X_Sparse_DMD>0;

figure;

k = 10;
subplottight(3,3,1), imshow(mat2gray(reshape(X(:,k), [im_h, im_w])), 'border', 'tight');
subplottight(3,3,2), imshow(mat2gray(reshape(Full_X_LowRank_DMD(:,k), [im_h, im_w])), 'border', 'tight');
subplottight(3,3,3), imshow(uint8(f_vid(:,:,:,k)), 'border', 'tight');

k = 50;
subplottight(3,3,4), imshow(mat2gray(reshape(X(:,k), [im_h, im_w])), 'border', 'tight');
subplottight(3,3,5), imshow(mat2gray(reshape(Full_X_LowRank_DMD(:,k), [im_h, im_w])), 'border', 'tight');
subplottight(3,3,6), imshow(uint8(f_vid(:,:,:,k)), 'border', 'tight');

k = 250;
subplottight(3,3,7), imshow(mat2gray(reshape(X(:,k), [im_h, im_w])), 'border', 'tight');
subplottight(3,3,8), imshow(mat2gray(reshape(Full_X_LowRank_DMD(:,k), [im_h, im_w])), 'border', 'tight');
subplottight(3,3,9), imshow(uint8(f_vid(:,:,:,k)), 'border', 'tight');
