% Set up the video writer object
writerObj = VideoWriter('peopleInShade');

writerObj.FrameRate = 60;
open(writerObj);

% Load the image frames from your folder
folder = "D:\Datasets\SciML\PROJECT\peopleInShade\input";
files = dir(fullfile(folder, '*.jpg'));
numFiles = length(files);

% Loop through the image frames and add them to the video writer object
for i = 1:numFiles
    filename = fullfile(folder, files(i).name);
    img = imread(filename);
    writeVideo(writerObj, img);
end

% Close the video writer object
close(writerObj);