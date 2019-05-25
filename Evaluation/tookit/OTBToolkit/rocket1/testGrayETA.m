basePath = '/home/winston/workSpace/PycharmProjects/tracking/TrackingGuidedInterpolation/Datasets/Original/OTB100';
videoName = dir(basePath); videoName = videoName(3:end);
ETA_ARR = [];
for vidx = 1:length(videoName)
    vidx
    imgSet = dir(fullfile(basePath,videoName(vidx).name,'img'));
    imgSet = imgSet(3:end);
    for frIdx = 1:length(imgSet)-1 % i i+1
        % for ever frame
        imgThis = imread(fullfile(basePath,videoName(vidx).name,'img',imgSet(frIdx).name));
        imgNext = imread(fullfile(basePath,videoName(vidx).name,'img',imgSet(frIdx+1).name));
        [h,w,c] = size(imgThis);
        grayThis = rgb2gray(imgThis);
        grayNext = rgb2gray(imgNext);
        eta = sum(sum((grayThis - grayNext) ./  grayThis)) / (w*h);
        ETA_ARR (end + 1) = eta;
    end
    vidx
end

