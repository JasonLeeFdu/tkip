%% VITAL 算法在Temple Color 128　上进行测试，测试代码的版本不需要进行多版本的backup
%% 这是一个多次执行取最大值的版本

path = mfilename('fullpath');
tmp = findstr(path,'/');
addpath(genpath(path(1:tmp(end))));
conf = config;
TC128Base = conf.BASE_PATH;
AdvBaselinePath = '/home/winston/workSpace/PycharmProjects/tracking/TrackingGuidedInterpolation/BaselineAdv/Vital';
addpath(genpath(AdvBaselinePath));



testAlg = {'VITAL'};
targetSet = 'TempleColor128';
trackers = ConfigMatTrackers;
seqNameBox = {};
GPU_ID = 1;


metricTypeSet = {'error', 'overlap'};
overWrite = false;

MAX_TRAIL_TIMES = 3;

resPathBase = fullfile(conf.BASE_PATH,'TheResults',strcat('BothRects_Choose2Center_BestPerf',num2str(MAX_TRAIL_TIMES)));
datasetBase = fullfile('/home/winston/Datasets/Tracking/Original',targetSet);
BASE_PATH = conf.BASE_PATH;
IF_RUN_ORI = false;

parallel.gpu.GPUDeviceManager.instance.selectDevice(GPU_ID)

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



for i = 1:length(testAlg)
    resSubPath = fullfile(resPathBase,testAlg{i}); %%%
    if ~exist(resSubPath,'dir')
       %mkdir(resSubPath);       
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
numSeq = length(videosList);
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

for idxVideo= 2:3:length(videosList)% 对于每一个视频(此处可以使用多进程)  
     disp([ '================== Run VITAL in Temple Color 128 set: vital_adv' ' --- ' ', ' num2str(idxVideo) '_' videosList(idxVideo).name '================== '])       
     completeFileName = sprintf('%s_%s_Adv.mat',videosList(idxVideo).name,trackers{1}.name);
     if exist(fullfile(resPathBase,completeFileName),'file')  && (~overWrite)
          fprintf([ 'Best Result --- '  num2str(idxVideo) '_' videosList(idxVideo).name]);
          fprintf(' is DONE! \n'); 
          continue;
     end
    for trailTimes = 1:MAX_TRAIL_TIMES
        fprintf('\n');
        disp(['====> ' num2str(trailTimes)   ]);
             %% get the imgSet
        videoClip = fullfile(datasetBase,videosList(idxVideo).name,'img') ;   
        imgSet = {};
        imagesInfo = dir(videoClip);  
        for i= 3:length(imagesInfo)
           imgSet{end+1} = fullfile(videoClip,imagesInfo(i).name) ;
        end    
        %% get the anno
        annoPath   = fullfile(datasetBase,videosList(idxVideo).name,[videosList(idxVideo).name '_gt.txt']);
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
            str0 = ['[resAdv ,InterpBboxAdv,MDEGArr,th,fpsAdv] = run_' t.name '_' 'ADV3_7_1' '(imgSet,init_rect,' num2str(-1) ');'];
            eval(str0);                       
            results = {}; 
            res = struct;
            res.startFrame = startFrame;
            res.endFrame   = endFrame;
            res.len        = endFrame - startFrame + 1;
            res.type       = 'rect';
            res.fps        =  fpsAdv;
            res.anno       = rect_anno;
            res.res        = double(resAdv);
            res.InterpBbox = InterpBboxAdv;
            res.th         = th;
            res.MDE        = MDEGArr;
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
    stdTc128ResFn = fullfile( resPathBase , sprintf('%s_%sAdv.txt',videosList(idxVideo).name,t.name));
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
    %% write the txt restuls
    dlmwrite(stdTc128ResFn,double(results{1,1}.res));
    disp('----------------------------------------------------');

end

fprintf('结束！');