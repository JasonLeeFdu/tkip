%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% get the perfMat data
%%%%%%% first, you should execute the former PerfPlot one
%%%%  

%% Ordinary Path config
addpath('./util');
attName={'illumination variation'	'out-of-plane rotation'	'scale variation'	'occlusion'	'deformation'	'motion blur'	'fast motion'	'in-plane rotation'	'out of view'	'background clutter' 'low resolution'};
attFigName={'illumination_variations'	'out-of-plane_rotation'	'scale_variations'	'occlusions'	'deformation'	'blur'	'abrupt_motion'	'in-plane_rotation'	'out-of-view'	'background_clutter' 'low_resolution'};
BASE_PATH = '/home/winston/workSpace/PycharmProjects/tracking/TrackingGuidedInterpolation/';
attPath = [BASE_PATH 'Evaluation/tookit/OTBToolkit' '/anno/att/']; 
perfMiddlePathPatch = 'Evaluation/results/perfMats'; % +Ideal2\Std2\StdInterp2
lastPathPatch = 'aveSuccessRatePlot_%dalg_%s_OPE.mat'; %1-num of alg  #2 metricTypeName
seqs=ConfigSeqs; 
trackersPy=ConfigTrackers;
trackersMat = ConfigMatTrackers;
trackers = [trackersPy,trackersMat];
numSeq=length(seqs);
numTrk=length(trackers);
SHOWTOTAL = true;
SHOWATT   = false;

%% Customed Path config
evalType = 'OPE'; 
% only one                                  
%downSampleTypeSet = {'Ideal','Std','StdInterp'};       % Ideal Original Std StdInterp           
downSampleTypeSet = {'Original','OriginalInterp'}; 


dBType = 'OTB50';                  % ONLY
dsRate = 2;
metricTypeSet = { 'error'};%metricTypeSet = {'error', 'overlap'};  
evalTypeSet = {evalType};
rankingType = 'AUC';          %AUC, threshold AUC
rankNum = 10;                       %number of plots to show
figPath = fullfile(BASE_PATH,'Evaluation/results/figs/overall');
%%% important path config
searchKeyModel='%s_%s%d';             % e.g. => 'overlap_Ideal2'
pathDict = containers.Map();

for i = 1:length(metricTypeSet)
   for j= 1:length(downSampleTypeSet)
       if strcmp(downSampleTypeSet{j},'Original')
         perfMatPath = fullfile(BASE_PATH,perfMiddlePathPatch,...
            downSampleTypeSet{j},dBType,...
            sprintf(lastPathPatch,numTrk,metricTypeSet{i}));
        
       else
           perfMatPath = fullfile(BASE_PATH,perfMiddlePathPatch,...
            strcat(downSampleTypeSet{j},num2str(dsRate)),dBType,...
            sprintf(lastPathPatch,numTrk,metricTypeSet{i}));
       end
        searchKey = sprintf(searchKeyModel,metricTypeSet{i},downSampleTypeSet{j},dsRate);
        pathDict(searchKey) = perfMatPath;
   end
end





plotDrawStyleAll={   struct('color',[0,0,0]/255,'lineStyle','-'),...
    struct('color',[255,127,39]/255,'lineStyle','-'),...
    struct('color',[255,255,0]/255,'lineStyle','-'),...
    struct('color',[0,0,0.1],'lineStyle','-'),...%    struct('color',[1,1,0],'lineStyle','-'),...%yellow
    struct('color',[1,0,1],'lineStyle','-'),...%pink
    struct('color',[0,1,1],'lineStyle','-'),...
    struct('color',[0.5,0.5,0.5],'lineStyle','-'),...%gray-25%
    struct('color',[136,0,21]/255,'lineStyle','-'),...%dark red
    struct('color',[255,127,39]/255,'lineStyle','-'),...%orange
    struct('color',[0,162,232]/255,'lineStyle','-'),...%Turquoise
    struct('color',[1,0,0],'lineStyle','-'),...%purple    %%%%%%%%%%%%%%%%%%%%
    struct('color',[1,0,0],'lineStyle','--'),...
    struct('color',[0,1,0],'lineStyle','--'),...
    struct('color',[0,0,1],'lineStyle','--'),...
    struct('color',[0,0,0],'lineStyle','--'),...%    struct('color',[1,1,0],'lineStyle','--'),...%yellow
    struct('color',[1,0,1],'lineStyle','--'),...%pink
    struct('color',[0,1,1],'lineStyle','--'),...
    struct('color',[0.5,0.5,0.5],'lineStyle','--'),...%gray-25%
    struct('color',[136,0,21]/255,'lineStyle','--'),...%dark red
    struct('color',[0,255,33]/255,'lineStyle','--'),...%orange
    struct('color',[0,162,232]/255,'lineStyle','--'),...%Turquoise
    struct('color',[163,73,164]/255,'lineStyle','--'),...%purple    %%%%%%%%%%%%%%%%%%%
    struct('color',[1,0,0],'lineStyle','-.'),...
    struct('color',[0,1,0],'lineStyle','-.'),...
    struct('color',[0,0,1],'lineStyle','-.'),...
    struct('color',[0,0,0],'lineStyle','-.'),...%    struct('color',[1,1,0],'lineStyle',':'),...%yellow
    struct('color',[1,0,1],'lineStyle','-.'),...%pink
    struct('color',[0,1,1],'lineStyle','-.'),...
    struct('color',[0.5,0.5,0.5],'lineStyle','-.'),...%gray-25%
    struct('color',[136,0,21]/255,'lineStyle','-.'),...%dark red
    struct('color',[255,127,39]/255,'lineStyle','-.'),...%orange
    struct('color',[0,162,232]/255,'lineStyle','-.'),...%Turquoise
    struct('color',[163,73,164]/255,'lineStyle','-.'),...%purple
    };

plotDrawStyle10={   struct('color',[1,0,0],'lineStyle','-'),...
    struct('color',[0,1,0],'lineStyle','--'),...
    struct('color',[0,0,1],'lineStyle',':'),...
    struct('color',[0,0,0],'lineStyle','-'),...%    struct('color',[1,1,0],'lineStyle','-'),...%yellow
    struct('color',[1,0,1],'lineStyle','--'),...%pink
    struct('color',[0,1,1],'lineStyle',':'),...
    struct('color',[0.5,0.5,0.5],'lineStyle','-'),...%gray-25%
    struct('color',[136,0,21]/255,'lineStyle','--'),...%dark red
    struct('color',[255,127,39]/255,'lineStyle',':'),...%orange
    struct('color',[0,162,232]/255,'lineStyle','-'),...%Turquoise
    };

seqs=ConfigSeqs; % start to config the seq part and set the path of the tracking res


% seqs = seqs(1:10);
% trackers = trackers(1:10);

numSeq=length(seqs);
numTrk=length(trackers);

nameTrkAll=cell(numTrk,1);
for idxTrk=1:numTrk
    t = trackers{idxTrk};
    nameTrkAll{idxTrk}=t.namePaper;
end

nameSeqAll=cell(numSeq,1);
numAllSeq=zeros(numSeq,1);


att=[];
for idxSeq=1:numSeq
    s = seqs{idxSeq};
    nameSeqAll{idxSeq}=s.name;
    attributeFileName = [attPath lower(s.name) '.txt'];
    att(idxSeq,:)=load(attributeFileName);
end

attNum = size(att,2);
if ~exist(figPath,'dir')
    mkdir(figPath);
end


if rankNum == 10
    plotDrawStyle=plotDrawStyleAll;
else
    plotDrawStyle=plotDrawStyleAll;
end

%%%%%%%%%%%%%%% 
thresholdSetOverlap = 0:0.05:1;
thresholdSetError = 0:50;


for i=1:length(metricTypeSet) % set error & overlap
    metricType = metricTypeSet{i};%error,overlap
    %%%$$$ mianji  zhongweishu
    switch metricType
        case 'overlap'
            thresholdSet = thresholdSetOverlap;
            rankIdx = 11;
            xLabelName = 'Overlap threshold';
            yLabelName = 'Success rate';
        case 'error'
            thresholdSet = thresholdSetError;
            rankIdx = 21;
            xLabelName = 'Location error threshold';
            yLabelName = 'Precision';
    end  
%         
%     if strcmp(metricType,'error') & strcmp(rankingType,'AUC')
%         continue;
%     end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    tNum = length(thresholdSet); 
    for j=1:length(evalTypeSet)
        
        evalType = evalTypeSet{j};%SRE, TRE, OPE
        
        plotType = [metricType '_' evalType];
        
        
        % e.g. => 'overlap_Ideal2'   metricTypeSet  downSampleTypeSet
      
        
        
        % if not generated, get it manually  'Ideal','Std','StdInterp'
        if (ismember('Original',downSampleTypeSet)&&ismember('OriginalInterp',downSampleTypeSet))
            dataNameOriginal = pathDict(sprintf(searchKeyModel,metricType,'Original',dsRate));
            dataNameOriginalInterp = pathDict(sprintf(searchKeyModel,metricType,'OriginalInterp',dsRate));
            pmO = load(dataNameOriginal);
            pmO = pmO.aveSuccessRatePlot;
            pmOI = load(dataNameOriginalInterp);
            pmOI = pmOI.aveSuccessRatePlot;
            pmSIP = cat(4,pmO,pmOI);
            
        else (ismember('Ideal',downSampleTypeSet) && ismember('Std',downSampleTypeSet)&&ismember('StdInterp',downSampleTypeSet))
            dataNameStd = pathDict(sprintf(searchKeyModel,metricType,'Std',dsRate));
            dataNameIdeal = pathDict(sprintf(searchKeyModel,metricType,'Ideal',dsRate));
            dataNameStdInterp = pathDict(sprintf(searchKeyModel,metricType,'StdInterp',dsRate));    
           	pmS = load(dataNameStd);
            pmS = pmS.aveSuccessRatePlot;
            pmI = load(dataNameIdeal);
            pmI = pmI.aveSuccessRatePlot;
            pmP = load(dataNameStdInterp);
            pmP = pmP.aveSuccessRatePlot;
            pmSIP = cat(4,pmS,pmI,pmP);
        end
        numTrk = size(pmSIP,1);        
        if SHOWTOTAL
           for k=1:numTrk
               trkName = trackers{k}.name;
               figName= [figPath '/' trkName 'Overall_' plotType '_' rankingType];
               idxSeqSet = 1:length(seqs);
               
               switch metricType
                    case 'overlap'
                        titleName = ['IOU Success plots of ' trkName];
                    case 'error'
                        titleName = ['Precision plots of ' trkName];
               end
               PlotDrawSave(dsRate,k,plotDrawStyle,pmSIP,idxSeqSet,rankingType,rankIdx,nameTrkAll,thresholdSet,titleName, xLabelName,yLabelName,figName,downSampleTypeSet);
            end
        end
        if SHOWATT
            for idxTrk=1:numTrk
                for attIdx=1:attNum % attNum of the attributes to be studied and displayed
                     idxSeqSet=find(att(:,attIdx)>0);
                     if length(idxSeqSet) < 2
                        continue;
                     end
                     disp([attName{attIdx} ' ' num2str(length(idxSeqSet))])
                     figName=[figPath attFigName{attIdx} '_'  plotType '_' rankingType];
                     titleName = ['Plots of ' trackers{idxTrk}.name  evalType ': ' attName{attIdx} ' (' num2str(length(idxSeqSet)) ')'];
                     switch metricType
                         case 'overlap'
                             titleName = ['Success plots of ' evalType ' - ' attName{attIdx} ' (' num2str(length(idxSeqSet)) ')'];
                         case 'error'
                             titleName = ['Precision plots of ' evalType ' - ' attName{attIdx} ' (' num2str(length(idxSeqSet)) ')'];
                     end
                     PlotDrawSave(dsRate,idxTrk,plotDrawStyle,pmSIP,idxSeqSet,rankingType,rankIdx,nameTrkAll,thresholdSet,titleName, xLabelName,yLabelName,figName,downSampleTypeSet);
                end    
            end
        end
    end
end

