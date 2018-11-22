%% This time we just make the detailed ori-adv comparision which contains
%% for sub-windows

%%%%%%%%%% config%%%%%%%%%%%%%%%%%%%%%%%%%
strategy = 'Adv';
global additionalNameTag
additionalNameTag = strategy;
testVideoSet = {'Biker'};%{'Basketball','Diving'  };
methodName_ = {'VITAL'};%{'ECO','VITAL'};
dBType = 'OTB100';
baseVideoSet = 'Original';
conf = config;
if strcmp(additionalNameTag,'')
    outputPath =  fullfile(conf.BASE_PATH,strcat('/Evaluation/results/vidvis3',strcat('_',additionalNameTag))); %%%%%% GET IT MODIFIED
else
    outputPath =  fullfile(conf.BASE_PATH,strcat('/Evaluation/results/vidvis3')); %%%%%% GET IT MODIFIED
end
isAllVideos = true;
isAllMethods = true;
isOverwrite = false;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
OriginalResPath= fullfile(conf.BASE_PATH,'/Evaluation/results/trackingResults/Original',dBType);
%OriginalInterpResPath = fullfile(conf.BASE_PATH,'/Evaluation/results/trackingResults/OriginalInterp2',dBType);
OriginalInterpResPath= fullfile(conf.BASE_PATH,'/Evaluation/results/AdvValidCheck');
baseVideoPath =  conf.DatasetPath(sprintf('%s_%s',baseVideoSet,dBType));

if ~exist(outputPath)
    mkdir(outputPath);
end
if isAllVideos
    testVideoSet = {};
    files = dir(baseVideoPath);
    for i =3:length(files)
        testVideoSet{end+1} = files(i).name;
    end
end

if isAllMethods
    methodName = {};
    trackersPy=ConfigTrackers;
    trackersMat = ConfigMatTrackers;
    trackers = trackersMat;
    %trackers = [trackersPy,trackersMat];
	for i =1:length(trackers)
        if ismember(trackers{i}.name,methodName_)
             methodName{end+1} = trackers{i}.name;
        end
	end
end

for idxVideo = 1:length(testVideoSet)
     append = -1;
     if any(ismember(conf.weirdVideoList, testVideoSet{idxVideo}))
            append = conf.OriginalStartEndF(testVideoSet{idxVideo});
     end
    for idxTrk = 1:length(methodName)
         fprintf('====================%s  ==  %s==============\n',testVideoSet{idxVideo},methodName{idxTrk});
        %1
        if strcmp(additionalNameTag,'')
            resVideoName = fullfile(outputPath,[testVideoSet{idxVideo} '-' methodName{idxTrk} '_visualization.avi']);
            videoClipPath = fullfile(baseVideoPath,testVideoSet{idxVideo},'img') ; %OTB50
            resFileNameOri = [testVideoSet{idxVideo} '_'    methodName{idxTrk}   '.mat'];
            resFileNameOriItp = resFileNameOri;
             
        else
            resVideoName = fullfile(outputPath,[testVideoSet{idxVideo} '-' methodName{idxTrk} '_' additionalNameTag '_visualization.avi']);
            videoClipPath = fullfile(baseVideoPath,testVideoSet{idxVideo},'img') ; %OTB50
            resFileNameOri = [testVideoSet{idxVideo} '_'    methodName{idxTrk} '.mat'];
            resFileNameOriItp = [testVideoSet{idxVideo} '_'    methodName{idxTrk} '_' additionalNameTag  '.mat'];;
        
        end
        if exist(resVideoName)&&~isOverwrite
             fprintf('Already FINISHED!\n');
            continue
        end
        %2 
        OriginRes = load(fullfile(OriginalResPath,resFileNameOri));

        OriginalInterpRes = load(fullfile(OriginalInterpResPath,resFileNameOriItp));
        
        %%%v1
        %OriginAnno= OriginRes.results{1,1}.anno;  
        %OriginRes = OriginRes.results{1,1}.res;        
        %%%v2
        OriginAnno= OriginRes.resultsOri{1,1}.anno;  
        OriginRes = OriginRes.resultsOri{1,1}.res; 
        
        
        OriginalInterpRes = OriginalInterpRes.resultsAdv{1,1}.res;
        %3
        imgFiles = dir(videoClipPath);
        imgSet = {};
        for i = 3:length(imgFiles)
         	imgSet{end+1} = fullfile(videoClipPath,imgFiles(i).name);
        end       
        bundleRes = cat(3,OriginAnno,OriginRes,OriginalInterpRes);        
        Visualization3([],imgSet, bundleRes, resVideoName,append); 
    end
end
