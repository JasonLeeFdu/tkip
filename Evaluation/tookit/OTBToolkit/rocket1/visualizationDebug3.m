%% test  some videoClip, mainly test the comparison of the original VITAL 
%% and the advanced vital
counterA = 0;
counterB = 0;
%%%%%%%%%% config%%%%%%%%%%%%%%%%%%%%%%%%%
strategy = 'Adv';
VIDEO_INTERP_CLIP_PATH = '/home/winston/Datasets/Tracking/OriginalInterp2/OTB100';
global additionalNameTag
additionalNameTag = strategy;
testVideoSet = {'Basketball'};%{'Basketball','Diving'  };
methodName_ = {'VITAL'};%{'ECO','VITAL'};
dBType = 'OTB100';
baseVideoSet = 'Original';
conf = config;
if strcmp(additionalNameTag,'')
    outputPath =  fullfile(conf.BASE_PATH,strcat('/Evaluation/results/vidvis3',strcat('_', additionalNameTag))); %%%%%% GET IT MODIFIED
else
    outputPath =  fullfile(conf.BASE_PATH,strcat('/Evaluation/results/vidvis3')); %%%%%% GET IT MODIFIED
end
isAllVideos = false;
isAllMethods = true;
isOverwrite = true;%false 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
OriginalResPath= fullfile(conf.BASE_PATH,'/Evaluation/results/trackingResults/Original',dBType);
%OriginalInterpResPath = fullfile(conf.BASE_PATH,'/Evaluation/results/trackingResults/OriginalInterp2',dBType);
OriginalInterpResPath= fullfile(conf.BASE_PATH,'/Evaluation/results/AdvValidCheckForDemo');
baseVideoPath =  conf.DatasetPath(sprintf('%s_%s',baseVideoSet,dBType));
fatalTxtFullName  = fullfile(OriginalInterpResPath,'fatalSeqList.txt');
fp=fopen(fullfile(OriginalInterpResPath,'A.txt'),'a'); 

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
            resFileNameOriItp = [testVideoSet{idxVideo} '_'    methodName{idxTrk} '_' additionalNameTag  '.mat'];
        
        end
        
        videoInterpClipPath = fullfile(VIDEO_INTERP_CLIP_PATH,testVideoSet{idxVideo},'img');
        
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
        OriginAnno= OriginRes.results{1,1}.anno;  
        OriginResRects = OriginRes.results{1,1}.res; 
        
        
        
        InterpBbox = OriginalInterpRes.results{1,1}.InterpBbox;
        OriginalInterpResRects = OriginalInterpRes.results{1,1}.res;
        
        %3
        imgFiles = dir(videoClipPath);
        imgSet = {};
        for i = 3:length(imgFiles)
         	imgSet{end+1} = fullfile(videoClipPath,imgFiles(i).name);
        end
        imgInterpFiles = dir(videoInterpClipPath);
        imgSetInterp = {};
        for i = 3:length(imgInterpFiles)
           imgSetInterp{end+1} = fullfile(videoInterpClipPath,imgInterpFiles(i).name); 
        end
        %% calculate and add IOU AUC datum
        thresholdSetOverlap = 0:0.05:1;
        thresholdSetError = 0:50;
        lenALL = size(OriginAnno,1);
%         try
            [z,zz, errCoverage, errCenter] = calcSeqErrRobust(OriginRes.results{1}, OriginAnno);
            for tIdx=1:length(thresholdSetOverlap)
                successNumOverlap(1,tIdx) = sum(errCoverage >thresholdSetOverlap(tIdx));
            end   
    %         for tIdx=1:length(thresholdSetError)
    %             successNumErr(1,tIdx) = sum(errCenter <= thresholdSetError(tIdx));
    %         end
            aveSuccessRatePlotOri(1,:) = successNumOverlap/(lenALL+eps);
    %         aveSuccessRatePlotErrOri(1,:) = successNumErr/(lenALL+eps);

            [z, zz, errCoverage, errCenter] = calcSeqErrRobust(OriginalInterpRes.results{1}, OriginAnno);
            for tIdx=1:length(thresholdSetOverlap)
                successNumOverlap(1,tIdx) = sum(errCoverage >thresholdSetOverlap(tIdx));
            end
    %         for tIdx=1:length(thresholdSetError)
    %             successNumErr(1,tIdx) = sum(errCenter <= thresholdSetError(tIdx));
    %         end
        
%         catch 
%             disp('有问题不能继续！')
%             break
%         end
        aveSuccessRatePlotAdv(1,:) = successNumOverlap/(lenALL+eps);
%         aveSuccessRatePlotErrAdv(1,:) = successNumErr/(lenALL+eps);
        
        aa=reshape(aveSuccessRatePlotOri,[1,length(thresholdSetOverlap)]);
        aa=aa(sum(aa,2)>0.00000000001,:);
        scoreIOUOri=mean(aa);
        
        
     	aa=reshape(aveSuccessRatePlotAdv,[1,length(thresholdSetOverlap)]);
        aa=aa(sum(aa,2)>0.00000000001,:);
        scoreIOUAdv=mean(aa);
        
%         aa=reshape(aveSuccessRatePlotErrOri,[1,length(thresholdSetError)]);
%         aa=aa(sum(aa,2)>0.00000000001,:);
%         scorePrecOri=mean(aa);
%         
%         
%      	aa=reshape(aveSuccessRatePlotErrAdv,[1,length(thresholdSetError)]);
%         aa=aa(sum(aa,2)>0.00000000001,:);
%         scorePrecAdv=mean(aa);
        statistics = [scoreIOUAdv,scoreIOUOri];
        bundleRes = cat(3,OriginAnno,OriginResRects,OriginalInterpResRects);        
        fatalFlag = Visualization3(InterpBbox,imgSet,imgSetInterp, bundleRes, resVideoName,append,statistics); 
        if fatalFlag  % record the fatal sequence's name
            fprintf(fp,'%s \n',testVideoSet{idxVideo});
        end
    end   
end
fclose(fp); 
