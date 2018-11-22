% with 'additionalNameTag' added
close all
clear;
clc
warning off all;
addpath('./util');
addpath(('./rstEval'));
seqs=ConfigSeqs;
trackers=ConfigMatTrackers;
numSeq=length(seqs);
numTrk=length(trackers);
conf = config;
strategy = 'LBP';
global additionalNameTag
additionalNameTag = strategy;

basePath = conf.BASE_PATH;
workingDirectory = mfilename('fullpath');

index_dir=findstr(workingDirectory,'/');
workingDirectory = workingDirectory(1:index_dir(end));
middlePart = conf.RES_MIDDLE_PART;
resType = 'trackingResults';                                         % 'trackingResults','perfMats','figs'
evalType = 'OPE';                                                    % 'OPE' None 只有OPE
downSampleTypeSet = {'OriginalInterp'};                              % {'Ideal','StdInterp','Std'}----- 'Original' 'Ideal','DS2','DSInterp2'  *‘StdInterpMutual’ 'OriginalInterp'


dBType = 'OTB50' ;                                                   % 'OTB50','OTB100','TempleColor128','VOT2016'
dsRate = 2;
overWrite = false;
annoResDimMatchCheck = false;

downSampleType = 'Original_And_OriginalInterp';

if strcmp(additionalNameTag,'')
    resMatFileNameModel = strcat('%s_%s', '.mat');
    resChoiceNameModel = strcat('Choice__%s_%s', '.mat');
else
    resMatFileNameModel = strcat('%s_%s_',additionalNameTag,'.mat');
    resChoiceNameModel = strcat('Choice__%s_%s_',additionalNameTag,'.mat');
end
datasetName = sprintf('%s%d_%s',downSampleType,dsRate,dBType);
resFileName = fullfile(basePath,middlePart,resType,strcat(downSampleType,num2str(dsRate)),dBType,resMatFileNameModel);
resChoiceFileName = fullfile(basePath,middlePart,resType,strcat(downSampleType,num2str(dsRate)),dBType,resChoiceNameModel);
   
OriDBPath  = conf.DatasetPath(sprintf('%s_%s','Original',dBType));
OriItpDBPath  = conf.DatasetPath(sprintf('%s%d_%s','OriginalInterp',dsRate,dBType));
videosList = dir(OriDBPath);
videosList = videosList(3:end);

for idxVideo= 1:length(videosList)
    %% get the imgSet
    OriVideoClipPath = fullfile(OriDBPath,videosList(idxVideo).name,'img') ;
    OriItpVideoClipPath = fullfile(OriItpDBPath,videosList(idxVideo).name,'img') ;
    imgSetOri = {};
    imgSetOriItp = {};
    imagesInfo = dir(OriVideoClipPath);  
    imagesItpInfo = dir(OriItpVideoClipPath);
    for i= 3:length(imagesInfo)
       imgSetOri{end+1} = fullfile(OriVideoClipPath,imagesInfo(i).name) ;
    end    
    for i= 3:length(imagesItpInfo)
       imgSetOriItp{end+1} = fullfile(OriItpVideoClipPath,imagesItpInfo(i).name);
    end    
    %% get the anno
    annoPath   = fullfile(OriDBPath,videosList(idxVideo).name,'groundtruth_rect.txt');
    rect_anno  = dlmread(annoPath);
    init_rect  = rect_anno(1,:); 
    flag = any(ismember(conf.weirdVideoList,videosList(idxVideo).name));
    if flag
            vdName = videosList(idxVideo).name;
            km = strcat(vdName,'_',num2str(dsRate));
            switch downSampleType 
                case 'Ideal'
                    tmp = conf.IdealStartEndF(km);
                    startFrame = tmp(1);
                    endFrame = tmp(2);

                case 'Std'
                    tmp = conf.StdStartEndF(km);
                    startFrame = tmp(1);
                    endFrame = tmp(2);
                case 'OriginalInterp'
                    km = km(1:end-2);
                    tmp = conf.OriginalInterpStartEndF(km);
                    startFrame = tmp(1);
                    endFrame = tmp(2);
                case 'StdInterp'
                    tmp = conf.StdInterpStartEndF(km);
                    startFrame = tmp(1);
                    endFrame = tmp(2);
                case 'Original'
                    km = km(1:end-2);
                    tmp = conf.OriginalStartEndF(km);
                    startFrame = tmp(1);
                    endFrame = tmp(2);    
                case 'Original_And_OriginalInterp'
                    km = km(1:end-2);
                    tmp = conf.OriginalInterpStartEndF(km);
                    startFrameOriItp = tmp(1);
                    endFrameOriItp = tmp(2);
                    tmp = conf.OriginalStartEndF(km);
                    startFrame = tmp(1);
                    endFrame = tmp(2);    
                    imgSetOriItp = imgSetOriItp(startFrameOriItp:endFrameOriItp);
            end
    else
        startFrame = 1;
        endFrame = length(imagesInfo)-2;
    end
    imgSetOri = imgSetOri(startFrame:endFrame);
    for idxTrk=1:numTrk     %For every tracker
        t = trackers{idxTrk};   % t is the name of the tracker
        % add the path
        algWorkingDirectory = t.workPath;
        cd (algWorkingDirectory);
        addpath(genpath(algWorkingDirectory));
        % validate the results  
        resFileSaveName = sprintf(resFileName,videosList(idxVideo).name,t.name);
        resChoiceFileNameFinal = sprintf(resChoiceFileName,videosList(idxVideo).name,t.name);
        if exist(resFileSaveName,'file') && (~overWrite)
                    load(resFileSaveName)
                    if annoResDimMatchCheck 
                           results = load(resFileSaveName) ;
                           results = results(1).results;
                    end
                   if any(size(results{1,1}.res)~= size(results{1,1}.anno))
                       results{1,1}.res = results{1,1}.res(1:2:end,:);
                       save(resFileSaveName, 'results');
                       fprintf([downSampleType ' --- ' num2str(idxTrk) '_' t.name ', ' num2str(idxVideo) '_' videosList(idxVideo).name]);
                       fprintf(' the results are fixed! \n');
                   end     
                 fprintf([downSampleType ' --- ' num2str(idxTrk) '_' t.name ', ' num2str(idxVideo) '_' videosList(idxVideo).name]);
                 fprintf(' is DONE! \n'); 
                continue;
        end
        
        disp([downSampleType ' --- ' num2str(idxTrk) '_' t.name ', ' num2str(idxVideo) '_' videosList(idxVideo).name])       
        [ress,fps,choice] = moduleMixRun1(t.name,imgSetOri,imgSetOriItp,rect_anno,strategy);
        
        results = {};
        res = struct;
        res.startFrame = startFrame;
        res.endFrame   = endFrame;
        res.len        = endFrame - startFrame + 1;
        res.type       = 'rect';
        res.fps        =  fps;
        rse.typeName   = downSampleType;
        res.anno       = rect_anno;
        res.dsRate     = dsRate;  
        res.res        = ress;
        results{end+1}  = res;
        
        save(resFileSaveName, 'results');
        save(resChoiceFileNameFinal, 'choice');
        cd (workingDirectory);
        rmpath(genpath(algWorkingDirectory));
    end
end

    
t=clock;
t=uint8(t(2:end));
disp([num2str(t(1)) '/' num2str(t(2)) ' ' num2str(t(3)) ':' num2str(t(4)) ':' num2str(t(5))]);
