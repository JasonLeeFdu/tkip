% Experiment1 Try to prove that the modified module is as same as the 
% original alg..
%%
%%用来测试，为局部光流算法选择阈值。  run_VITAL_ADV3_4
% 1. read the database
% 2. get the result seperately
% 3. get the total line-graph and separate vXt chart 
%%

%% The fixed version that calls run_VITAL_Adv1 funtion to track while 
%% record all the bbox of the whole interpolated 
%% All we have to run is adv because we already have the results of the ori-method
%% (But this time we would like to do a sanity check of the alg code)


OTBToolkitBase = '/home/winston/workSpace/PycharmProjects/tracking/TrackingGuidedInterpolation/Evaluation/tookit/OTBToolkit';
AdvBaselinePath = '/home/winston/workSpace/PycharmProjects/tracking/TrackingGuidedInterpolation/BaselineAdv/Vital';
addpath(genpath(OTBToolkitBase));
addpath(genpath(AdvBaselinePath));


conf = config;
loconf = localConfig();
testAlg = {'VITAL'};
targetSet = 'OTB100';
trackers=ConfigMatTrackers;
seqs=ConfigSeqs100;
seqNameBox = {};
numSeq=length(seqs);
metricTypeSet = {'error', 'overlap'};
overWrite = false;
%%% 第三次搜索阈值，用来查找光流阈值
resPathBase = fullfile('/home/winston/workSpace/PycharmProjects/tracking/TrackingGuidedInterpolation/Evaluation/results','AdvValidCheckForDemoFth3Opt');
datasetBase = fullfile('/home/winston/Datasets/Tracking/Original',targetSet);

BASE_PATH = conf.BASE_PATH;
IF_RUN_ORI = false;


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
idxVideoSet = loconf.idxVideoSet; %按照官网的标注精选十个视频，覆盖所有的标签，七个视频多标签，三个视频集中于快速运动尺度变化外观变化，，时长较长
for idxVideoIdx=1:6:length(idxVideoSet) %% Here to do the paralell things
    idxVideo = idxVideoSet(idxVideoIdx);
    for localOptTh = loconf.thArr3
        fprintf('++++++++++++++++++++++++++++++++++++++++++++R thresh : %f ++++++++++++++++++++++++++++++++++++++++++++',localOptTh)
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
            resAdvFileSaveName = sprintf('%s_%s_Adv__%f.mat',videosList(idxVideo).name,t.name,localOptTh);
            if exist(fullfile(resPathBase,resAdvFileSaveName),'file')  && (~overWrite)
                     fprintf([ 'Sanity check --- ' num2str(idxTrk) '_' t.name ', ' num2str(idxVideo) '_' videosList(idxVideo).name]);
                     fprintf(' is DONE! \n'); 
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
                     fprintf(' is DONE! \n'); 
                    continue;
            end
            results = {};
            results = {};

            %%%
            saveAdv =  fullfile(resPathBaseTrk,resAdvFileSaveName);
            %%%
            disp([ 'AdvBaseline Validation check fixed version1: ADV' ' --- ' num2str(idxTrk) '_' t.name ', ' num2str(idxVideo) '_' videosList(idxVideo).name])       
            str0 = ['[result ,Interp_bbox,MDEGArr,th,fps ] = run_' t.name '_' 'ADV3_4'  '(imgSet,init_rect,localOptTh);'];
            eval(str0); 
            results = {};
            res = struct;
            res.startFrame = startFrame;
            res.endFrame   = endFrame;
            res.len        = endFrame - startFrame + 1;
            res.type       = 'rect';
            res.fps        =  fps;
            res.anno       = rect_anno;
            res.res        = result;
            res.InterpBbox = Interp_bbox;
            res.MDE     = MDEGArr;
            res.th = th;
            
            results{end+1}  = res;
            save(saveAdv, 'results');

            cd (workingDirectory);
            rmpath(genpath(algWorkingDirectory));
        end
    end

end
