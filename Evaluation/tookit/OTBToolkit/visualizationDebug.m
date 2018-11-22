% test  some videoClip
%%%%%%%%%% config%%%%%%%%%%%%%%%%%%%%%%%%%
strategy = 'OVI';
global additionalNameTag
additionalNameTag = strategy;
testVideoSet = {'Biker'};%{'Basketball','Diving'  };
methodName = {'STRCF'};%{'ECO','VITAL'};
dBType = 'OTB50';
baseVideoSet = 'Original';
conf = config;
if strcmp(additionalNameTag,'')
    outputPath =  fullfile(conf.BASE_PATH,strcat('/Evaluation/results/vidvis1',strcat('_',additionalNameTag))); %%%%%% GET IT MODIFIED
else
    outputPath =  fullfile(conf.BASE_PATH,strcat('/Evaluation/results/vidvis1')); %%%%%% GET IT MODIFIED
end
isAllVideos = false;
isAllMethods = true;
isOverwrite = true;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
OriginalResPath= fullfile(conf.BASE_PATH,'/Evaluation/results/trackingResults/Original',dBType);
%OriginalInterpResPath = fullfile(conf.BASE_PATH,'/Evaluation/results/trackingResults/OriginalInterp2',dBType);
OriginalInterpResPath= fullfile(conf.BASE_PATH,'/Evaluation/results/trackingResults/Original_And_OriginalInterp2',dBType);
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
         methodName{end+1} = trackers{i}.name;
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
            choiceFileName = ['Choice__' testVideoSet{idxVideo} '_'    methodName{idxTrk} '.mat'];        
        else
            resVideoName = fullfile(outputPath,[testVideoSet{idxVideo} '-' methodName{idxTrk} '_' additionalNameTag '_visualization.avi']);
            videoClipPath = fullfile(baseVideoPath,testVideoSet{idxVideo},'img') ; %OTB50
            resFileNameOri = [testVideoSet{idxVideo} '_'    methodName{idxTrk} '.mat'];
            resFileNameOriItp = [testVideoSet{idxVideo} '_'    methodName{idxTrk} '_' additionalNameTag  '.mat'];;
            choiceFileName = ['Choice__' testVideoSet{idxVideo} '_'    methodName{idxTrk} '_' additionalNameTag '.mat'];        
        end
        if exist(resVideoName)&&~isOverwrite
             fprintf('Already FINISHED!\n');
            continue
        end
        %2 
        OriginRes = load(fullfile(OriginalResPath,resFileNameOri));
        choiceRes = load(fullfile(OriginalInterpResPath,choiceFileName));
        choiceRes = choiceRes.choice;
        OriginalInterpRes = load(fullfile(OriginalInterpResPath,resFileNameOriItp));
        OriginAnno= OriginRes.results{1,1}.anno;  
        OriginRes = OriginRes.results{1,1}.res;        
        OriginalInterpRes = OriginalInterpRes.results{1,1}.res;
        %3
        imgFiles = dir(videoClipPath);
        imgSet = {};
        for i = 3:length(imgFiles)
                imgSet{end+1} = fullfile(videoClipPath,imgFiles(i).name);
        end       
        bundleRes = cat(3,OriginAnno,OriginRes,OriginalInterpRes);        
        Visualization(choiceRes,imgSet, bundleRes, resVideoName,append); 
    end
end
