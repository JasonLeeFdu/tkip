videoName = 'Walking2'
saveNum = 66;
savePath = 'a';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
videoDirProto = '/home/winston/Datasets/Tracking/Original/OTB100/%s/img/';
videoDir = sprintf(videoDirProto,videoName);
framesInfo = dir(videoDir);framesInfo = framesInfo(3:end);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
SiampMatFn = sprintf('/home/winston/workSpace/PycharmProjects/tracking/TrackingGuidedInterpolation/Evaluation/results/trackingResults/stateoftheart/OTB100/%s_SiamRPN++.mat',videoName);
VITALMatFn = sprintf('/home/winston/workSpace/PycharmProjects/tracking/TrackingGuidedInterpolation/Evaluation/results/trackingResults/stateoftheart/OTB100/%s_VITAL.mat',videoName);
ECOMatFn = sprintf('/home/winston/workSpace/PycharmProjects/tracking/TrackingGuidedInterpolation/Evaluation/results/trackingResults/stateoftheart/OTB100/%s_ECO.mat',videoName);
DSLTMatFn = sprintf('/home/winston/workSpace/PycharmProjects/tracking/TrackingGuidedInterpolation/Evaluation/results/trackingResults/stateoftheart/OTB100/%s_DSLT.mat',videoName);
JROTMMatFn = sprintf('/home/winston/workSpace/PycharmProjects/tracking/TrackingGuidedInterpolation/Evaluation/results/trackingResults/stateoftheart/OTB100/%s_VITAL_Adv.mat',videoName);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load(SiampMatFn); Sr = results{1,1}.res;
load(VITALMatFn); Vr = results{1,1}.res;
load(ECOMatFn); Er = results{1,1}.res;
load(DSLTMatFn); Dr = results{1,1}.res;
load(JROTMMatFn); Jr = results{1,1}.res;
gtr = results{1,1}.anno;


Sclr = [0 0 0];
Vclr = [0 0 255];
Eclr = [0 255 0];
Dclr = [0 255 255];
Jclr = [255 255 0];
gtclr = [255 0 0];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% out = VideoWriter(fullfile(savePath,[videoName '.avi']));       
% out.FrameRate = 50;
% out.Quality = 95;
% open(out);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


for i = 1:length(framesInfo)
    imgFn = fullfile(videoDir,framesInfo(i).name);
    
    si = IOU(gtr(i,:),Sr(i,:));
    vi = IOU(gtr(i,:),Vr(i,:));
    ei = IOU(gtr(i,:),Er(i,:));
    di = IOU(gtr(i,:),Dr(i,:));
    ji = IOU(gtr(i,:),Jr(i,:));
    flag = (si<ji)&&(vi<ji)&&(ei<ji)&&(di<ji);
    if flag
        % fr num
        img   = imread(imgFn);
        img = insertText(img,[3 3],['#' num2str(i)],'FontSize',28,'TextColor','yellow','BoxOpacity',0.0);
        % rects
        img = drawRect( img,Sr(i,:), 1, Sclr ,'x1y1wh');
        img = drawRect( img,Vr(i,:), 1, Vclr ,'x1y1wh');
        img = drawRect( img,Er(i,:), 1, Eclr ,'x1y1wh');
        img = drawRect( img,Dr(i,:), 1, Dclr ,'x1y1wh');
        img = drawRect( img,Jr(i,:), 1, Jclr ,'x1y1wh');
        img = drawRect( img,gtr(i,:), 1, gtclr ,'x1y1wh');
        img = drawRect( img,Dr(i,:), 1, Dclr ,'x1y1wh');
        imwrite(img,fullfile(savePath,[videoName '_frame_' num2str(i) '.png']));
        disp('YYYYYYYYYYYYYYYEEEEEEEEEEEEEEEAAAAAAAAAAAAAAAHHHHHHHHHHHHHH');
    end
    
    i
    
end
    
    
%close(out);    
    
    
    
    
    
    
