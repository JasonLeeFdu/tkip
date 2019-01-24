imgPath = '/home/winston/workSpace/PycharmProjects/tracking/TrackingGuidedInterpolation/Datasets/OriginalInterp2/VOT2016/blanket';
imgSets  = dir(imgPath);
imgSets  = imgSets(3:end);
imgSet   = cell(1,length(imgSets));
for i = 1:length(imgSets)
    imgSet{i} = fullfile(imgPath,imgSets(i).name);
end


TO = 37;
toto = 2 * TO - 2

interpAlg(imgSet,TO);

