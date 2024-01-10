%% Convert video into .mat
clear all; close all; clc

% video name
vid_path = "D:\Datasets\SciML\PROJECT\videos\peopleInShade.avi";

% import video
v = VideoReader(vid_path);

n_frames = 0;
while hasFrame(v)
    frame = readFrame(v);
    video(:,:,:,1+n_frames) = imresize(frame, [1/2*v.Height 1/2*v.Width]); % rescale video
    n_frames = n_frames+1;
end

% video dimensions
im_h=size(video,1);
im_w=size(video,2);

% create colummated data matrix, one snapshot per column
for i=1:size(video,4)
    image  = im2double(rgb2gray(video(:,:,:,i)));
    X(:,i) = reshape(image,[im_h*im_w,1]);
end

% save video as matrix
% save('ski_drop_low.mat','video');
% save('ski_drop_low__colummated','X');
save("D:\Datasets\SciML\PROJECT\matrix\peopleInShade.mat",'video');
save('D:\Datasets\SciML\PROJECT\matrix\peopleInShade_columnated','X');