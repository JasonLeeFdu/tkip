

datasetBase = fullfile('/home/winston/Datasets/Tracking/Original','OTB100');
if ~strcmp(datasetBase(end),'/')
    datasetBase = strcat(datasetBase,'/');
end
videosList = dir(datasetBase);
videosList = videosList(3:end);

lcf = localConfig();
avgAUC_th_Arr = zeros(length(lcf.thArr1),1);
videoNum  = length(lcf.idxVideoSet);
%%%
ResPath   = '/home/winston/workSpace/PycharmProjects/tracking/TrackingGuidedInterpolation/Evaluation/results/AdvValidCheckForDemoFth1/';
THRESHOLDSETOVERLAP = lcf.THRESHOLDSETOVERLAP;
thArrCounter = 1;




for thresh = lcf.thArr1 
    avg = 0.0;
    movieCounter = 1;
    for idxVideoClip = lcf.idxVideoSet
        %% %%%%%Compute the AVG AUC
        % load the file
        fn = strcat(videosList(idxVideoClip).name,'_VITAL_Adv__',sprintf('%f',thresh),'.mat');
        load(fullfile(ResPath,fn))
        anno = results{1,1}.anno;
        res = results{1,1}.res;       
        % calculate the 
        [aveCoverage, aveErrCenter, errCoverage, errCenter] = calcSeqErrRobust(results{1,1}, results{1,1}.anno);
        for tIdx=1:length(THRESHOLDSETOVERLAP)
            successNumOverlap(tIdx) = sum(errCoverage > THRESHOLDSETOVERLAP(tIdx));
        end
        lenALL = size(anno,1);
        %% 'aveSuccessRatePlot' is the line of every 'thresh' and 'movie':
        %% % movie X Thresh
        aveSuccessRatePlot(movieCounter,:) = successNumOverlap/(lenALL+eps); % shape is 1 X 21
        % calculate
        movieCounter = movieCounter + 1;
    end
    AUC_EveryMovie = mean(aveSuccessRatePlot,2);     % A
    avgAUC_th_Arr(thArrCounter) = mean(AUC_EveryMovie);
    thArrCounter = thArrCounter + 1;
end

figure;
plot(lcf.thArr1,avgAUC_th_Arr);
axis([0.0 1.0 0.0 1.0]) 
title('10个代表视频的IOU曲线AUC平均值，算法：全局差分，大运动插帧');
xlabel('需要插帧大运动百分比');ylabel('十个视频平均IOU曲线AUC值');
legend('全局差分');

