function GenPerfMat1(seqs, trackers, evalType, perfMatPath, trkResPath,additionalNameTag)
% additionalNameTag is for Ori or Adv
numTrk = length(trackers);
nameTrkAll=cell(numTrk,1);
for idxTrk=1:numTrk
    t = trackers{idxTrk};
    nameTrkAll{idxTrk}=t.namePaper;
end

thresholdSetOverlap = 0:0.05:1;
thresholdSetError = 0:50;
rpAll = trkResPath;
evalType =  'OPE';
for idxSeq=1:length(seqs)  
    s = seqs{idxSeq};    
    for idxTrk=1:numTrk  
        t = trackers{idxTrk};
        load([rpAll s.name '_' t.name '_' additionalNameTag  '.mat']) 
        disp([s.name ' ' t.name]);
        aveCoverageAll=[];
        aveErrCenterAll=[];
        errCvgAccAvgAll = 0;
        errCntAccAvgAll = 0;
        errCoverageAll = 0;
        errCenterAll = 0;
        lenALL = 0;
        idxNum = 1;idx = 1;
        
        successNumOverlap = zeros(idxNum,length(thresholdSetOverlap));
        successNumErr = zeros(idxNum,length(thresholdSetError));
        %%%% 
        Instruction1 = ['res = results' additionalNameTag  '{1};'];
        eval(Instruction1);
        
        anno = res.anno;
            
        len = size(anno,1);
          
        if isempty(res.res)
           break;
        end
            
        if ~isfield(res,'type')&&isfield(res,'transformType')
            res.type = res.transformType;
            res.res = res.res';
         end
            
        %%%%%%%%%%% This is very important.
        [aveCoverage, aveErrCenter, errCoverage, errCenter] = calcSeqErrRobust(res, anno);
        for tIdx=1:length(thresholdSetOverlap)
            successNumOverlap(idx,tIdx) = sum(errCoverage >thresholdSetOverlap(tIdx));
        end
        for tIdx=1:length(thresholdSetError)
            successNumErr(idx,tIdx) = sum(errCenter <= thresholdSetError(tIdx));
        end
        lenALL = lenALL + len;
        %%%%%  
        if strcmp(evalType, 'OPE')
            aveSuccessRatePlot(idxTrk, idxSeq,:) = successNumOverlap/(lenALL+eps);
            aveSuccessRatePlotErr(idxTrk, idxSeq,:) = successNumErr/(lenALL+eps);
        else
            aveSuccessRatePlot(idxTrk, idxSeq,:) = sum(successNumOverlap)/(lenALL+eps);
            aveSuccessRatePlotErr(idxTrk, idxSeq,:) = sum(successNumErr)/(lenALL+eps);
        end
        
    end
end
%

if strcmp(additionalNameTag,'')
    dataName1=[perfMatPath 'aveSuccessRatePlot_' num2str(numTrk) 'alg_overlap_' evalType '.mat'];
    save(dataName1,'aveSuccessRatePlot','nameTrkAll');
    dataName2=[perfMatPath 'aveSuccessRatePlot_' num2str(numTrk) 'alg_error_' evalType '.mat'];
    aveSuccessRatePlot = aveSuccessRatePlotErr;
    save(dataName2,'aveSuccessRatePlot','nameTrkAll');
else
    dataName1=[perfMatPath 'aveSuccessRatePlot_' num2str(numTrk) 'alg_overlap_' evalType '_' additionalNameTag '.mat'];
    save(dataName1,'aveSuccessRatePlot','nameTrkAll');
    dataName2=[perfMatPath 'aveSuccessRatePlot_' num2str(numTrk) 'alg_error_' evalType '_' additionalNameTag '.mat'];
    aveSuccessRatePlot = aveSuccessRatePlotErr;
    save(dataName2,'aveSuccessRatePlot','nameTrkAll');
end