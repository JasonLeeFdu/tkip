function GenPerfMat2(seqs, trackers, evalType, perfMatPath, trkResPath,nameTrkAll)
global additionalNameTag;

numTrk = length(trackers);

thresholdSetOverlap = 0:0.05:1;
thresholdSetError = 0:50;
rpAll = trkResPath;

for idxSeq=1:length(seqs)  
    s = seqs{idxSeq};    
    % get the standard anno
    t= {};
    for pp=1:numTrk  
       t = trackers{pp};
       if ~strcmp('VITAL_Adv',t.name) continue;end
    end
    results = {};
    load([rpAll s.name '_' t.name '.mat']);
    if isempty(results)
        res = resultsAdv{1};
        results{end+1}=res;
        save([rpAll s.name '_' t.name '.mat'],'results')
    
    else
        res = results{1};
    end
    
    
    standardAnno = res.anno;
    
    for idxTrk=1:numTrk  
        t = trackers{idxTrk};
        if strcmp(additionalNameTag,'')
            load([rpAll s.name '_' t.name '.mat'])
        else
            load([rpAll s.name '_' t.name '_' additionalNameTag  '.mat']) 
        end
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
        res = results{1};
        
        anno = standardAnno;
            
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
    dataName1=[perfMatPath 'aveSuccessRatePlot_' num2str(numTrk) 'alg_overlap_' evalType '_stateoftheart.mat'];
    save(dataName1,'aveSuccessRatePlot','nameTrkAll');
    dataName2=[perfMatPath 'aveSuccessRatePlot_' num2str(numTrk) 'alg_error_' evalType '_stateoftheart.mat'];
    aveSuccessRatePlot = aveSuccessRatePlotErr;
    save(dataName2,'aveSuccessRatePlot','nameTrkAll');
else
    dataName1=[perfMatPath 'aveSuccessRatePlot_' num2str(numTrk) 'alg_overlap_' evalType '_' additionalNameTag '_stateoftheart.mat'];
    save(dataName1,'aveSuccessRatePlot','nameTrkAll');
    dataName2=[perfMatPath 'aveSuccessRatePlot_' num2str(numTrk) 'alg_error_' evalType '_' additionalNameTag '_stateoftheart.mat'];
    aveSuccessRatePlot = aveSuccessRatePlotErr;
    save(dataName2,'aveSuccessRatePlot','nameTrkAll');
end