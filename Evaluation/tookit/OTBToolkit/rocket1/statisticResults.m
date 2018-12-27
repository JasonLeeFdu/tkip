function [IOU_AUC_Total,Pres_Med_Total,IOU_AUC_Mtrx,Pres_Med_Mtrx] = statisticResults(resPath)%rsePath)
    %STATISTICRESULTS Summary of this function goes here
    %   Detailed explanation goes here
    lc = localConfig;
    seqs=ConfigSeqs100;
    thresholdSetOverlap = lc.THRESHOLDSETOVERLAP;
    thresholdSetError   = lc.THRESHOLDSETERROR;
    successNumOverlap = zeros(1,length(thresholdSetOverlap));
  	successNumErr = zeros(1,length(thresholdSetError));
    for idxSeq = 1:length(seqs)
        vname = seqs{idxSeq}.name;
        resFn = strcat(vname,'_VITAL_Adv.mat');
        load(fullfile(resPath,resFn));
        anno = results{1,1}.anno;
        len = size(anno,1);
        [~, ~, errCoverage, errCenter] = calcSeqErrRobust(results{1,1}, anno);
        for tIdx=1:length(thresholdSetOverlap)
            successNumOverlap(idxSeq,tIdx) = sum(errCoverage > thresholdSetOverlap(tIdx));
        end
        for tIdx=1:length(thresholdSetError)
            successNumErr(idxSeq,tIdx) = sum(errCenter <= thresholdSetError(tIdx));
        end
        lenALL = 0 + len;
        successNumOverlap(idxSeq,:) = successNumOverlap(idxSeq,:) / (lenALL+eps);
        successNumErr(idxSeq,:) = successNumErr(idxSeq,:) / (lenALL+eps);
        %%%%%  
    end
    %% IOU_AUC_Total
    line = mean(successNumOverlap);
    IOU_AUC_Total = mean(line);
    %% IOU_AUC_Mtrx
    IOU_AUC_Mtrx = mean(successNumOverlap,2);
    
    %% Pres_Med_Total
    line = mean(successNumErr);
    Pres_Med_Total = line(lc.RANKID);
    %% Pres_Med_Mtrx
    Pres_Med_Mtrx = zeros(length(seqs),1);
    for i = 1:length(seqs)
        linee = successNumErr(i,:);
        Pres_Med_Mtrx(i) = linee(lc.RANKID);
    end
end

