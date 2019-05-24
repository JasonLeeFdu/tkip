clear
close all;
clc
%% COMPARE WITH THE STATE OF THE ART

strategy = '';
addpath('./util');
attName={'illumination variation'	'out-of-plane rotation'	'scale variation'	'occlusion'	'deformation'	'motion blur'	'fast motion'	'in-plane rotation'	'out of view'	'background clutter' 'low resolution'};
attFigName={'illumination_variations'	'out-of-plane_rotation'	'scale_variations'	'occlusions'	'deformation'	'blur'	'abrupt_motion'	'in-plane_rotation'	'out-of-view'	'background_clutter' 'low_resolution'};
BASE_PATH = '/home/winston/workSpace/PycharmProjects/tracking/TrackingGuidedInterpolation/';
attPath = [BASE_PATH 'Evaluation/tookit/OTBToolkit' '/anno/att/']; % The folder that contains the annotation files for sequence attributes
strategy = '';
global additionalNameTag;
additionalNameTag = strategy;
isDrawTotal = true;

%%%%%%%%%  About path  %%%%%%%%%%%%
                                     
evalType = 'OPE';                       % only one                                  
downSampleType = 'stateoftheart';    	% Ideal Original Std StdInterp       OriginalInterp     
dBType = 'OTB100';                      % 'OTB100' 'OTB50' 'VOT2016'
dsRate = 2;


trackersPy=[];%ConfigTrackers;
trackersMat = ConfigStateofArtMatTrackers;
trackers = [trackersPy,trackersMat];

metricTypeSet = {'overlap','error'};
evalTypeSet = {'OPE'};
rankingType = 'AUC'; %AUC, threshold AUC
rankNum = 18;%number of plots to show
drawAttrGraph= false;
% start to config the seq part and set the path of the tracking res  ConfigSeqs



if strcmp(dBType,'OTB50')
    dBType_ = 'OTB100';
    seqs=ConfigSeqs;
elseif strcmp(dBType,'OTB100')
    dBType_ = dBType;
    seqs=ConfigSeqs100;
else
    dBType_ = dBType;
    seqs=ConfigSeqs100;
end


figPath = strcat(fullfile(BASE_PATH,'Evaluation/results/figs',fullfile(strcat(downSampleType,num2str(dsRate)),dBType_)),'/');
if strcmp(downSampleType,'Original')==1 || strcmp(downSampleType,'stateoftheart')==1
    perfMatPath = strcat(fullfile(BASE_PATH,'Evaluation/results/perfMats',fullfile(downSampleType),dBType),'/');
    trkResPath = strcat(fullfile(BASE_PATH ,'Evaluation/results/trackingResults/',fullfile(downSampleType),dBType_),'/');
else
   perfMatPath = strcat(fullfile(BASE_PATH,'Evaluation/results/perfMats',fullfile(strcat(downSampleType,num2str(dsRate)),dBType)),'/');
   trkResPath = strcat(fullfile(BASE_PATH ,'Evaluation/results/trackingResults/',fullfile(strcat(downSampleType,num2str(dsRate)),dBType_)),'/');
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

for idxTrk=1:numTrk
    t = trackers{idxTrk};
    nameTrkAll{idxTrk}=t.namePaper;
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
                %titleName = [dBType strcat(downSampleType ) '- IOU Success plots of ' evalType];
                titleName = ['OTB-100' '  IOU Success plots of ' evalType];
            case 'error'
                %titleName = [dBType strcat(downSampleType ) '- Precision plots of ' evalType];
                titleName = ['OTB-100' '  Precision plots of ' evalType];
        end
        
        %%
        if strcmp(additionalNameTag,'')
            dataName = [perfMatPath 'aveSuccessRatePlot_' num2str(numTrk) 'alg_'  plotType '_stateoftheart.mat'];
        else
            dataName = [perfMatPath 'aveSuccessRatePlot_' num2str(numTrk) 'alg_'  plotType '_' additionalNameTag '_stateoftheart.mat'];
        end
        
        % If the performance Mat file, dataName, does not exist, it will call
        % genPerfMat to generate the file.
        %if ~exist(dataName)
        GenPerfMat2(seqs, trackers, evalType, perfMatPath,trkResPath,nameTrkAll); %% send in all the trackers and seqs
        %end        

        load(dataName);
        numTrk = size(aveSuccessRatePlot,1);        
        
        if rankNum > numTrk | rankNum <0
            rankNum = numTrk;
        end
        
        figName= [figPath 'quality_plot_' plotType '_' rankingType];
        idxSeqSet = 1:length(seqs);
        
        % draw and save the overall performance plot
        if isDrawTotal
            plotDrawSave(numTrk,plotDrawStyle,aveSuccessRatePlot,idxSeqSet,rankNum,rankingType,rankIdx,nameTrkAll,thresholdSet,titleName, xLabelName,yLabelName,figName,metricType);
        end
        
        % draw and save the performance plot for each attribute
        TAR = 11;
        if drawAttrGraph 
                 attTrld = 0;
            for attIdx=1:attNum % attNum of the attributes to be studied and displayed
                if attIdx ~= TAR
                   continue; 
                end
                idxSeqSet=find(att(:,attIdx)>attTrld);

                if length(idxSeqSet) < 2
                    continue;
                end
                disp([attName{attIdx} ' ' num2str(length(idxSeqSet))])

                figName=[figPath attFigName{attIdx} '_'  plotType '_' rankingType];
                titleName = ['Plots of ' evalType ': ' attName{attIdx} ' (' num2str(length(idxSeqSet)) ')'];
                switch metricType
                    case 'overlap'
                        titleName = ['OTB-100 Success ' evalType ':' attName{attIdx} ' (' num2str(length(idxSeqSet)) ')'];
                        rankingType = 'AUC'; 
                    case 'error'
                        titleName = ['OTB-100 Precision ' evalType ':' attName{attIdx} ' (' num2str(length(idxSeqSet)) ')'];
                        rankingType = 'threshold';
                end
                plotDrawSave(numTrk,plotDrawStyle,aveSuccessRatePlot,idxSeqSet,rankNum,rankingType,rankIdx,nameTrkAll,thresholdSet,titleName, xLabelName,yLabelName,figName,metricType);
            end   
        end
    end
end
