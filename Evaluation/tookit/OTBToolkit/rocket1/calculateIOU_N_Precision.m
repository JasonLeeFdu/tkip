function [IOU_AUC,Precs_Thres] = calculateIOU_N_Precision(resFileName)
    load(resFileName);
    anno = results{1,1}.anno;
    res  = results{1,1}.res;
    lcf = localConfig;
    THRESHOLDSETOVERLAP = lcf.THRESHOLDSETOVERLAP;
    THRESHOLDSETERROR = lcf.THRESHOLDSETERROR;
    RANKID = lcf.RANKID;
    %%% get IOU_AUG
    [aveCoverage, aveErrCenter, errCoverage, errCenter] = calcSeqErrRobust(results{1,1}, results{1,1}.anno);
    for tIdx=1:length(THRESHOLDSETOVERLAP)
          	successNumOverlap(tIdx) = sum(errCoverage > THRESHOLDSETOVERLAP(tIdx));         
    end       
    lenALL = size(anno,1);
    %% 'aveSuccessRatePlot' is the line of every 'thresh' and 'movie':
    %% % movie X Thresh
    aveSuccessRatePlot = successNumOverlap/(lenALL+eps); % shape is 1 X 21
    IOU_AUC = mean(aveSuccessRatePlot);
    

    
    %%% get Preecs_Thres
   for tIdx=1:length(THRESHOLDSETERROR)
            successNumErr(tIdx) = sum(errCenter <= THRESHOLDSETERROR(tIdx));
   end
   aveSuccessRatePlotErr = successNumErr/(lenALL+eps); % shape is 1 X 21
   Precs_Thres = aveSuccessRatePlotErr(RANKID);
   

end

