function [IOU_AUC_Total,Pres_Med_Total,IOU_AUC_Mtrx,Pres_Med_Mtrx] = evaluateSequenceAUC(resPath,trName)
    %得到该算法结果路径下,该算法对于所有每个视频片段得到的 AUC 数据
    %%%%%% 唯一一个需要修改的地方是这里
    JROTMPATH = '/home/winston/workSpace/PycharmProjects/tracking/TrackingGuidedInterpolation/Evaluation/results/trackingResults/stateoftheart/OTB100/';
    %%%%%%
    lc = localConfig;
    seqs=ConfigSeqs100;
    thresholdSetOverlap = lc.THRESHOLDSETOVERLAP;
    thresholdSetError   = lc.THRESHOLDSETERROR;
    successNumOverlap = zeros(1,length(thresholdSetOverlap));
  	successNumErr = zeros(1,length(thresholdSetError));
    for idxSeq = 1:length(seqs)
        vname = seqs{idxSeq}.name;
        %% 读取VITAL的anno
        JROTM_GT_FN = strcat(vname,'_VITAL_Adv.mat');
        load(fullfile(JROTMPATH,JROTM_GT_FN));
        anno = results{1,1}.anno;
        %% 读取算法的结果results
        tkFn = [vname, '_' , trName, '.mat'];
        clear results;
        load(fullfile(resPath,tkFn));
        len  = size(results{1,1}.res,1);
        %% 
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

