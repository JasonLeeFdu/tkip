clear
close all;
clc


strategy = '';
addpath('./util');
attName={'illumination variation'	'out-of-plane rotation'	'scale variation'	'occlusion'	'deformation'	'motion blur'	'fast motion'	'in-plane rotation'	'out of view'	'background clutter' 'low resolution'};
attFigName={'illumination_variations'	'out-of-plane_rotation'	'scale_variations'	'occlusions'	'deformation'	'blur'	'abrupt_motion'	'in-plane_rotation'	'out-of-view'	'background_clutter' 'low_resolution'};
BASE_PATH = '/home/winston/workSpace/PycharmProjects/tracking/TrackingGuidedInterpolation/';
attPath = [BASE_PATH 'Evaluation/tookit/OTBToolkit' '/anno/att/']; % The folder that contains the annotation files for sequence attributes
strategy = 'LBP';
global additionalNameTag;
additionalNameTag = strategy;

%%%%%%%%%  About path  %%%%%%%%%%%%
                                     
evalType = 'OPE';                  % only one                                  
downSampleType = 'Original_And_OriginalInterp';         % Ideal Original Std StdInterp       OriginalInterp     
dBType = 'OTB50';                  % 'OTB100' 'OTB50' 'VOT2016'
dsRate = 2;


trackersPy=[];%ConfigTrackers;
trackersMat = ConfigMatTrackers;
trackers = [trackersPy,trackersMat];

metricTypeSet = {'error', 'overlap'};
evalTypeSet = {'OPE'};
rankingType = 'AUC'; %AUC, threshold AUC
rankNum = 10;%number of plots to show
drawAttrGraph= true;


figPath = strcat(fullfile(BASE_PATH,'Evaluation/results/figs',fullfile(strcat(downSampleType,num2str(dsRate)),dBType)),'/');
if strcmp(downSampleType,'Original')==1
    perfMatPath = strcat(fullfile(BASE_PATH,'Evaluation/results/perfMats',fullfile(downSampleType),dBType),'/');
    trkResPath = strcat(fullfile(BASE_PATH ,'Evaluation/results/trackingResults/',fullfile(downSampleType),dBType),'/');
else
   perfMatPath = strcat(fullfile(BASE_PATH,'Evaluation/results/perfMats',fullfile(strcat(downSampleType,num2str(dsRate)),dBType)),'/');
   trkResPath = strcat(fullfile(BASE_PATH ,'Evaluation/results/trackingResults/',fullfile(strcat(downSampleType,num2str(dsRate)),dBType)),'/');
end

plotDrawStyleAll={   struct('color',[1,0,0],'lineStyle','-'),...
    struct('color',[0,1,0],'lineStyle','-'),...
    struct('color',[0,0,1],'lineStyle','-'),...
    struct('color',[0,0,0],'lineStyle','-'),...%    struct('color',[1,1,0],'lineStyle','-'),...%yellow
    struct('color',[1,0,1],'lineStyle','-'),...%pink
    struct('color',[0,1,1],'lineStyle','-'),...
    struct('color',[0.5,0.5,0.5],'lineStyle','-'),...%gray-25%
    struct('color',[136,0,21]/255,'lineStyle','-'),...%dark red
    struct('color',[255,127,39]/255,'lineStyle','-'),...%orange
    struct('color',[0,162,232]/255,'lineStyle','-'),...%Turquoise
    struct('color',[163,73,164]/255,'lineStyle','-'),...%purple    %%%%%%%%%%%%%%%%%%%%
    struct('color',[1,0,0],'lineStyle','--'),...
    struct('color',[0,1,0],'lineStyle','--'),...
    struct('color',[0,0,1],'lineStyle','--'),...
    struct('color',[0,0,0],'lineStyle','--'),...%    struct('color',[1,1,0],'lineStyle','--'),...%yellow
    struct('color',[1,0,1],'lineStyle','--'),...%pink
    struct('color',[0,1,1],'lineStyle','--'),...
    struct('color',[0.5,0.5,0.5],'lineStyle','--'),...%gray-25%
    struct('color',[136,0,21]/255,'lineStyle','--'),...%dark red
    struct('color',[255,127,39]/255,'lineStyle','--'),...%orange
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
global additionalNameTag
additionalNameTag = strategy;
seqs=ConfigSeqs; % start to config the seq part and set the path of the tracking res
% seqs = seqs(1:10);
% trackers = trackers(1:10);

numSeq=length(seqs);
numTrk=length(trackers);

nameTrkAll=cell(numTrk,1);
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
    plotDrawStyle=plotDrawStyle10;
else
    plotDrawStyle=plotDrawStyleAll;
end

%%%%%%%%%%%
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
         
    
    tNum = length(thresholdSet);
    
    for j=1:length(evalTypeSet)
        
        evalType = evalTypeSet{j};%SRE, TRE, OPE
        
        plotType = [metricType '_' evalType];
        
        switch metricType
            case 'overlap'
                titleName = [strcat(downSampleType,num2str(dsRate)) '- IOU Success plots of ' evalType];
            case 'error'
                titleName = [strcat(downSampleType,num2str(dsRate)) '- Precision plots of ' evalType];
        end
        
        %%
        if strcmp(additionalNameTag,'')
            dataName = [perfMatPath 'aveSuccessRatePlot_' num2str(numTrk) 'alg_'  plotType '.mat'];
        else
            dataName = [perfMatPath 'aveSuccessRatePlot_' num2str(numTrk) 'alg_'  plotType '_' additionalNameTag '.mat'];
        end
        
        % If the performance Mat file, dataName, does not exist, it will call
        % genPerfMat to generate the file.
        if ~exist(dataName)
            GenPerfMat(seqs, trackers, evalType, perfMatPath,trkResPath,nameTrkAll); %% send in all the trackers and seqs
        end        

        load(dataName);
        numTrk = size(aveSuccessRatePlot,1);        
        
        if rankNum > numTrk | rankNum <0
            rankNum = numTrk;
        end
        
        figName= [figPath 'quality_plot_' plotType '_' rankingType];
        idxSeqSet = 1:length(seqs);
        
        % draw and save the overall performance plot
        plotDrawSave(numTrk,plotDrawStyle,aveSuccessRatePlot,idxSeqSet,rankNum,rankingType,rankIdx,nameTrkAll,thresholdSet,titleName, xLabelName,yLabelName,figName,metricType);
        
        % draw and save the performance plot for each attribute
        if drawAttrGraph 
                 attTrld = 0;
            for attIdx=1:attNum % attNum of the attributes to be studied and displayed

                idxSeqSet=find(att(:,attIdx)>attTrld);

                if length(idxSeqSet) < 2
                    continue;
                end
                disp([attName{attIdx} ' ' num2str(length(idxSeqSet))])

                figName=[figPath attFigName{attIdx} '_'  plotType '_' rankingType];
                titleName = ['Plots of ' evalType ': ' attName{attIdx} ' (' num2str(length(idxSeqSet)) ')'];
                switch metricType
                    case 'overlap'
                        titleName = [strcat(downSampleType,num2str(dsRate)) '- Success plots of ' evalType ' - ' attName{attIdx} ' (' num2str(length(idxSeqSet)) ')'];
                    case 'error'
                        titleName = [strcat(downSampleType,num2str(dsRate)) '- Precision plots of ' evalType ' - ' attName{attIdx} ' (' num2str(length(idxSeqSet)) ')'];
                end
                plotDrawSave(numTrk,plotDrawStyle,aveSuccessRatePlot,idxSeqSet,rankNum,rankingType,rankIdx,nameTrkAll,thresholdSet,titleName, xLabelName,yLabelName,figName,metricType);
            end   
        end
    end
end
