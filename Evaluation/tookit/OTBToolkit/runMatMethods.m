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

basePath = conf.BASE_PATH;
workingDirectory = mfilename('fullpath');

index_dir=findstr(workingDirectory,'/');
workingDirectory = workingDirectory(1:index_dir(end));


middlePart = conf.RES_MIDDLE_PART;
resType = 'trackingResults';                                         % 'trackingResults','perfMats','figs'
evalType = 'OPE';                                                    % 'OPE' None 只有OPE
downSampleTypeSet = {'Original'};                              % {'Ideal','StdInterp','Std'}----- 'Original' 'Ideal','DS2','DSInterp2'  *‘StdInterpMutual’ 'OriginalInterp'


dBType = 'OTB50' ;                                                   % 'OTB50','OTB100','TempleColor128','VOT2016'
dsRate = 2;
overWrite = false;
annoResDimMatchCheck = false;

for idxDownSampleType = 1:length(downSampleTypeSet)
    
    downSampleType = downSampleTypeSet{idxDownSampleType};
    fprintf(strcat('======================',downSampleType,'=================================\n\n'));
    resMatFileNameModel = '%s_%s.mat';
    if strcmp(downSampleType,'Original')==1
        datasetName = sprintf('%s_%s',downSampleType, dBType);
    else
        datasetName = sprintf('%s%d_%s',downSampleType,dsRate,dBType);
    end
    downSampleTypeNRate = downSampleType + num2str(dsRate);
    
    if strcmp(downSampleType,'Original')==1
       databasePath  = conf.DatasetPath(sprintf('%s_%s',downSampleType,dBType));
       resFileName = fullfile(basePath,middlePart,resType, downSampleType ,dBType,resMatFileNameModel);
    else
       databasePath  = conf.DatasetPath(sprintf('%s%d_%s',downSampleType,dsRate,dBType));
       resFileName = fullfile(basePath,middlePart,resType,strcat(downSampleType,num2str(dsRate)),dBType,resMatFileNameModel);
    end   
    videosList = dir(databasePath);
    videosList = videosList(3:end);
    for idxVideo=1:length(videosList)
        %% get the imgSet
        videoClipPath = fullfile(databasePath,videosList(idxVideo).name,'img') ;
        imgSet = {};
        imagesInfo = dir(videoClipPath);
        for i= 3:length(imagesInfo)
           imgSet{end+1} = fullfile(videoClipPath,imagesInfo(i).name) ;
        end
        %% get the anno
        annoPath   = fullfile(databasePath,videosList(idxVideo).name,'groundtruth_rect.txt');
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
                end
            else
                startFrame = 1;
                endFrame = length(imagesInfo)-2;
        end
        imgSet = imgSet(startFrame:endFrame);
        for idxTrk=1:numTrk     %For every tracker
            t = trackers{idxTrk};   % t is the name of the tracker
            % add the path
            
            
            algWorkingDirectory = t.workPath;
            cd (algWorkingDirectory);
            addpath(genpath(algWorkingDirectory));
            % validate the results
            resFileSaveName = sprintf(resFileName,videosList(idxVideo).name,t.name);
            if exist(resFileSaveName,'file') && (~overWrite)
                        if annoResDimMatchCheck 
                               results = load(resFileSaveName) ;
                               results = results(1).results;
                        end
                       load(resFileSaveName) ;
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
            results = {};
            disp([downSampleType ' --- ' num2str(idxTrk) '_' t.name ', ' num2str(idxVideo) '_' videosList(idxVideo).name])       
            funcName = ['[ress,fps] = run_' t.name '(imgSet,init_rect);'];
            try  
                eval(funcName);             %%%$$$ Execute the  string as a sentence of a function,
                                            %  res = run_VR(subS, rp, bSaveImage)         
            catch err
                disp('error');
                rmpath(genpath('./'))
                cd('../../');
                res=[];
                continue;
            end
            switch downSampleType
                case 'Ideal'
                    idx = 1:dsRate:size(ress,1);
                    ress = ress(idx,:);
            	case 'StdInterp'
                    idx = 1:dsRate:size(ress,1);
                    ress = ress(idx,:);
                 case 'OriginalInterp'
                    idx = 1:dsRate:size(ress,1);
                    ress = ress(idx,:);
            end
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
            cd (workingDirectory);
            rmpath(genpath(algWorkingDirectory));
        end
    end
end
t=clock;
t=uint8(t(2:end));
disp([num2str(t(1)) '/' num2str(t(2)) ' ' num2str(t(3)) ':' num2str(t(4)) ':' num2str(t(5))]);

