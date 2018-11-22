%%%%%%%%%%%%%%%%%%  CONFIG %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
evalType = 'OPE';                                                                                 % only one                                  
downSampleTypeSet = {'Original','Original_And_OriginalInterp'};                          % Ideal Original Std StdInterp       OriginalInterp     
dBType = 'OTB50';                                                                               % 'OTB100' 'OTB50' 'VOT2016'
dsRate = 2;
metricTypeSet = {'error', 'overlap'};
evalTypeSet = {'OPE'};
isAttr = false;
specAttr = 'FM';
trackersMat=ConfigMatTrackers;
trackersPy = []; %ConfigMatTrackers; ConfigTrackers
trackers = [trackersPy,trackersMat];
rankingType = 'AUC'; %AUC, threshold AUC
rankNum = 10;%number of plots to show
strategy = 'LBP';
global additionalNameTag
additionalNameTag = strategy;

%%%%%%%%%%%%%%%%%% PREPARATIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
drawAttrGraph= false;
conf = config;
BASE_PATH = conf.BASE_PATH;
seqs=ConfigSeqs; % start to config the seq part and set the path of the tracking res

numSeqs = length(seqs);
numTrk   = length(trackers);
savePath = fullfile(BASE_PATH, 'Evaluation/results/mmAnalysis');
suffixSaveName = '';
for i = 1:length(downSampleTypeSet)
   suffixSaveName = strcat(suffixSaveName, downSampleTypeSet{i}(1));
end
saveName = fullfile(savePath, ['movieMethodAnalysis_' suffixSaveName  '.mat']);
saveVName = fullfile(savePath, ['movieMethodAnalysis_VNames_' suffixSaveName  '.mat']);
saveBName = fullfile(savePath, ['movieMethodAnalysis_BNames_' suffixSaveName  '.mat']);
saveASName = fullfile(savePath, ['movieMethodAnalysis_AttrStr_' suffixSaveName  '.mat']);
if ~exist(savePath)
    mkdir(savePath);
end
seqNames = {};
for i=1:length(seqs)
    seqNames{end+1} = seqs{i}.name;
end
seqNames = seqNames';
trkNames = {};
for i=1:length(trackers)
    trkNames{end+1} = trackers{i}.name;
end
attrNames  = {'光照变化, ','平面外旋转, ','尺度变化, ','遮挡, ','形变, ','运动模糊, ','快速运动, ','平面内旋转, ','丢失视角, ','背景杂乱, ','低分辨率, '};
attrNamesEnglish = {'IV','OPR','SV','OCC','DEF','MB','FM','IPR','OV','BC','LR'};
attPath = [BASE_PATH 'Evaluation/tookit/OTBToolkit' '/anno/att/']; % The folder that contains the annotation files for sequence attributes
attStringSet={};
att = [];
for idxSeq=1:numSeqs
    s = seqs{idxSeq};
    nameSeqAll{idxSeq}=s.name;
    attributeFileName = [attPath lower(s.name) '.txt'];
    tmp = load(attributeFileName);
    recIdx = find(tmp);
    att(idxSeq,:)= tmp;
    recStr = '';
    for i = 1:length(recIdx)
        recStr = strcat(recStr,attrNames{recIdx(i)});
    end
    attStringSet{end+1} = recStr;
end
%%%%%%%%%%%%%%%%%%%%%CALCULATION%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
deltaMetric = zeros(numSeqs,numTrk);
resIntetmediate = {};
attStringSet = attStringSet';
for idxDownSampleType = 1:length(downSampleTypeSet)
    downSampleType = downSampleTypeSet{idxDownSampleType};
    for idxMetricType = 1:length(metricTypeSet)
        metricType = metricTypeSet{idxMetricType};
        plotType = [metricType '_' evalType];
        if strcmp(downSampleType,'Original')==1
            perfMatPath = strcat(fullfile(BASE_PATH,'Evaluation/results/perfMats',fullfile(downSampleType),dBType),'/');
            dataName = [perfMatPath 'aveSuccessRatePlot_' num2str(numTrk) 'alg_'  plotType '.mat'];
        else
            perfMatPath = strcat(fullfile(BASE_PATH,'Evaluation/results/perfMats',fullfile(strcat(downSampleType,num2str(dsRate)),dBType)),'/');
            if strcmp(additionalNameTag,'')
                dataName = [perfMatPath 'aveSuccessRatePlot_' num2str(numTrk) 'alg_'  plotType '.mat'];
            else
                dataName = [perfMatPath 'aveSuccessRatePlot_' num2str(numTrk) 'alg_'  plotType '_' additionalNameTag '.mat'];
            end
        end
        load(dataName); % get the aveSuccessRatePlot OF: 
        tmpMtrx = aveSuccessRatePlot; % #Movies * #Baseline * #threshold
        tmpMtrx = mean(tmpMtrx,3);     % AUC of  % #Movies * #Baseline 
        resIntetmediate{end+1} = tmpMtrx;
   end
end
%%%%%%%%%%%%%%%%%%     Save important results   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
mtrxOriginal = ( resIntetmediate{1} +  resIntetmediate{2} )/2;
mtrxOriginalInterp = ( resIntetmediate{3} +  resIntetmediate{4} )/2;
resMtrx = mtrxOriginalInterp -  mtrxOriginal ;
resMtrx = resMtrx';  
save(saveName,'resMtrx');  
save(saveVName,'seqNames');  
save(saveBName,'trkNames');  
save(saveASName,'attStringSet');  
hm = heatmap(resMtrx);

%%%%%%%%%%%%%%%%%%%%%% SPECIFIC ATTRIBUTE STUDY  %%%%%%%%%%%%%%%%%%%%%%%%%
attrNamesEnglish = {'IV','OPR','SV','OCC','DEF','MB','FM','IPR','OV','BC','LR'};
if isAttr
    specAttr = 'IPR';
    IndexC = strfind(attrNamesEnglish, specAttr);
    indexAttr = find(not(cellfun('isempty', IndexC)));
    idxSeqSet=find(att(:,indexAttr)>0.1);
    resMtrxAtt = resMtrx(idxSeqSet,:);
    seqNamesAtt = seqNames(idxSeqSet,:);
    attStringSetAtt = attStringSet(idxSeqSet,:);
    save([saveName(1:end-4) 'att_' specAttr '.mat'],'resMtrxAtt');  
    save([saveVName(1:end-4) 'att_' specAttr '.mat'],'seqNamesAtt');  
    save([saveASName(1:end-4) 'att_' specAttr '.mat'],'attStringSetAtt');
    hm = heatmap(resMtrxAtt);
    
end




