% Experiment1 Try to prove that the modified module is as same as the 
% original alg..

%%
% 1. read the database
% 2. get the result seperately
% 3. get the total line-graph and separate vXt chart 
%%

%%  就是用来跑光流增强算法的！,而且是从20个结果里面挑选最好的作为最终的结果
%%  请用来测试一下差分法的性能(看一下全局、局部的结果)


OTBToolkitBase = '/home/winston/workSpace/PycharmProjects/tracking/TrackingGuidedInterpolation/Evaluation/tookit/OTBToolkit';
AdvBaselinePath = '/home/winston/workSpace/PycharmProjects/tracking/TrackingGuidedInterpolation/BaselineAdv/Vital';
addpath(genpath(OTBToolkitBase));
addpath(genpath(AdvBaselinePath));

BEST_TH = 0.03;
conf = config;
testAlg = {'VITAL'};
targetSet = 'OTB100';
trackers=ConfigMatTrackers;
seqs=ConfigSeqs100;
seqNameBox = {};
numSeq=length(seqs);
metricTypeSet = {'error', 'overlap'};
overWrite = false;
resPathBase = fullfile('/home/winston/workSpace/PycharmProjects/tracking/TrackingGuidedInterpolation/Evaluation/results','MotionDiffOpt1_Best');
datasetBase = fullfile('/home/winston/Datasets/Tracking/Original',targetSet);

BASE_PATH = conf.BASE_PATH;
IF_RUN_ORI = false;
MAX_TRAIL_TIMES = 10;


if ~strcmp(resPathBase(end),'/')
    resPathBase = strcat(resPathBase,'/');
end
if ~strcmp(datasetBase(end),'/')
    datasetBase = strcat(datasetBase,'/');
end
basePath = conf.BASE_PATH;
workingDirectory = mfilename('fullpath');

index_dir=findstr(workingDirectory,'/');
workingDirectory = workingDirectory(1:index_dir(end));

if ~exist(resPathBase,'dir')
    mkdir(resPathBase);
end

for i = 1:length(seqs)
    seqNameBox {end+1} = seqs{i}.name;
end


for i = 1:length(testAlg)
    resSubPath = fullfile(resPathBase,testAlg{i}); %%%
    if ~exist(resSubPath,'dir')
       mkdir(resSubPath);       
    end
end

for i = 1:length(testAlg)
    if ~ismember(trackers{i}.name,testAlg)
        trackers(i) = [];
    end
end
attrNames  = {'光照变化, ','平面外旋转, ','尺度变化, ','遮挡, ','形变, ','运动模糊, ','快速运动, ','平面内旋转, ','丢失视角, ','背景杂乱, ','低分辨率, '};
attrNamesEnglish = {'IV','OPR','SV','OCC','DEF','MB','FM','IPR','OV','BC','LR'};
attPath = [BASE_PATH 'Evaluation/tookit/OTBToolkit' '/anno/att/']; % The folder that contains the annotation files for sequence attributes
attStringSet={};
att = [];

numTrk=length(trackers);
videosList = dir(datasetBase);
videosList = videosList(3:end);
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 针对每一个视频
% 1.首先进行10次运算
% >  循环求解，注意保存新的文件名(非标准文件名，例如Bike_VITAL_Adv(1).mat)
%
% 2.然后找到里面效果最好的，并统计算法对于该算法的方差
% >  便利每一个文件，计算其AUC+Median,以此作为标准筛选最大的文件
% >> 顺便记录统计每一个视频的，每一次结果的AUC、Median，然后求出每一个视频的AUC、Median的方差、均值(MOVIE x [AUC Median] x [均值 方差])
%
% 3.选择这个作为最终结果，进行下一个视频
% >  对文件进行拷贝，生成标准文件，然后进行所有的删除
% 
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





doneFlagVid = false;

for idxVideo=  48 %length(videosList)% 对于每一个视频(此处可以使用多进程)  
     disp([ '================== AdvBaseline Validation check fixed version1: ADV' ' --- ' ', ' num2str(idxVideo) '_' videosList(idxVideo).name '================== '])       

     completeFileName = sprintf('%s_%s_Adv.mat',videosList(idxVideo).name,trackers{1}.name);
     if exist(fullfile(resPathBase,completeFileName),'file')  && (~overWrite)
                  fprintf([ 'Best Result --- '  num2str(idxVideo) '_' videosList(idxVideo).name]);
                  fprintf(' is DONE! \n'); 
                  continue;
     end
    for trailTimes = 1:MAX_TRAIL_TIMES
        disp(['====> ' num2str(trailTimes)   ]);
             %% get the imgSet
        videoClip = fullfile(datasetBase,videosList(idxVideo).name,'img') ;   
        imgSet = {};
        imagesInfo = dir(videoClip);  
        for i= 3:length(imagesInfo)
           imgSet{end+1} = fullfile(videoClip,imagesInfo(i).name) ;
        end    
        %% get the anno
        annoPath   = fullfile(datasetBase,videosList(idxVideo).name,'groundtruth_rect.txt');
        rect_anno  = dlmread(annoPath);
        init_rect  = rect_anno(1,:); 

        %% check if the video in the weirdList
        flag = any(ismember(conf.weirdVideoList,videosList(idxVideo).name));
        if flag
            vdName = videosList(idxVideo).name;
            km = vdName;
            tmp = conf.OriginalStartEndF(km);
            startFrame = tmp(1);
            endFrame = tmp(2);    
        else
            startFrame = 1;
            endFrame = length(imagesInfo)-2;
        end
        imgSet = imgSet(startFrame:endFrame);


        for idxTrk=1:numTrk     %For every tracker
            t = trackers{idxTrk};   % t is the name of the tracker
            resPathBaseTrk = resPathBase;       


            % add the path
            algWorkingDirectory = AdvBaselinePath;
            cd (algWorkingDirectory);
            addpath(genpath(algWorkingDirectory));
            % validate the results  
            resOriFileSaveName = sprintf('%s_%s_Ori.mat',videosList(idxVideo).name,t.name);      
            resAdvFileSaveName = sprintf('%s_%s_Adv(%d).mat',videosList(idxVideo).name,t.name,trailTimes);
            
            if exist(fullfile(resPathBase,resAdvFileSaveName),'file')  && (~overWrite)
                     fprintf([ 'Best Result --- ' num2str(idxTrk) '_' t.name ', ' num2str(idxVideo) '_' videosList(idxVideo).name]);
                     fprintf(' %d is DONE! \n',trailTimes); 
                    continue;
            end
            if exist(resAdvFileSaveName,'file') && (~overWrite)
                        load(resAdvFileSaveName)
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
                     fprintf(' %d is DONE! \n',trailTimes); 
                    continue;
            end
            results = {};
            results = {};

            %%%
            saveAdv =  fullfile(resPathBaseTrk,resAdvFileSaveName);
            %%%
            str0 = ['[resAdv ,InterpBboxAdv,MDEGArr,th,fpsAdv] = run_' t.name '_' 'ADV3_4' '(imgSet,init_rect,' num2str(BEST_TH) ');'];
            eval(str0);                       
            results = {}; 
            res = struct;
            res.startFrame = startFrame;
            res.endFrame   = endFrame;
            res.len        = endFrame - startFrame + 1;
            res.type       = 'rect';
            res.fps        =  fpsAdv;
            res.anno       = rect_anno;
            res.res        = resAdv;
            res.InterpBbox = InterpBboxAdv;
            res.th = th;
            res.MDE     = MDEGArr;
            results{end+1}  = res;
            save(saveAdv, 'results');
            cd (workingDirectory);
            rmpath(genpath(algWorkingDirectory));
        end 
    end
    disp('');
    %% After doing the OPE   calculateIOU_N_Precision
    resFnSet = {};
    IOUArr   = [];
    PrecArr  = [];
    Metyrc   = [];
    for kk = 1:MAX_TRAIL_TIMES
        resFnSet{kk} = fullfile( resPathBase , sprintf('%s_%s_Adv(%d).mat',videosList(idxVideo).name,t.name,kk));
    end
    for kk = 1:MAX_TRAIL_TIMES
        [IOU_AUC,Precs_Thres] = calculateIOU_N_Precision(resFnSet{kk});
        IOUArr(kk) = IOU_AUC;
        PrecArr(kk) = Precs_Thres;
    end
    Metyrc = (IOUArr + PrecArr)/2;
    [argvalue, argmax] = max(Metyrc);
    
    stdResFn = fullfile( resPathBase , sprintf('%s_%s_Adv.mat',videosList(idxVideo).name,t.name));
    bestResFn = fullfile( resPathBase , sprintf('%s_%s_Adv(%d).mat',videosList(idxVideo).name,t.name,argmax));
    copyfile(bestResFn, stdResFn);
    % remove the (kk) files
    for kk = 1:length(resFnSet)
        delete(resFnSet{kk});
    end
    % inject statistic
    load(stdResFn);
    results{1,1}.IOUArr = IOUArr;    
    results{1,1}.PrecArr = PrecArr;
    save(stdResFn,'results');
    disp('----------------------------------------------------');

end
downSampleTypeSet = {'Ori','Adv'};
GenPerfMat3(seqs, trackers, 'OPE', resPathBase, resPathBase,downSampleTypeSet{1});
GenPerfMat3(seqs, trackers, 'OPE', resPathBase, resPathBase,downSampleTypeSet{2});
deltaMetric = zeros(numSeq,numTrk);
resIntetmediate = {};

attStringSet = attStringSet';

for idxDownSampleType = 1:length(downSampleTypeSet)
    additionalNameTag = downSampleTypeSet{idxDownSampleType};
    for idxMetricType = 1:length(metricTypeSet)
        metricType = metricTypeSet{idxMetricType};
        plotType = [metricType '_OPE'];
        perfMatPath = resPathBase;
        if ~ strcmp(additionalNameTag,'')
            dataName = [perfMatPath 'aveSuccessRatePlot_' num2str(numTrk) 'alg_'  plotType '_' additionalNameTag '.mat'];
        else
            dataName = [perfMatPath 'aveSuccessRatePlot_' num2str(numTrk) 'alg_'  plotType '.mat'];
        end
        % error_OPE_Ori   overlap_OPE_Ori
        % error_OPE_Adv    %overlap_OPE_Adv 
        load(dataName); % get the aveSuccessRatePlot OF: 
        tmpMtrx = aveSuccessRatePlot; %  #Baseline * #Movies * #threshold
        [~,s1,s2] = size(tmpMtrx);
        tmpMtrx = reshape(tmpMtrx,[s1,s2]);
        tmpMtrx = mean(tmpMtrx,2);     % AUC of  % #Movies * #Baseline 
        resIntetmediate{end+1} = tmpMtrx; % 
   end
end
fprintf('结束！');
