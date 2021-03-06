%% Conf %%

%%%%%%%%%%


    
conf = config;


vs = dir('/home/winston/workSpace/PycharmProjects/tracking/TrackingGuidedInterpolation/Datasets/Original2/OTB100/');
for j = 3:length(vs)
    vn = vs(j).name
    N = length(dir(sprintf(BASEMod,vn))) - 2;
    if exist(fullfile('/home/winston/workSpace/PycharmProjects/tracking/TrackingGuidedInterpolation/Evaluation/results/vidvis3/',strcat(vn,'.avi'))) || exist(fullfile('/home/winston/workSpace/PycharmProjects/tracking/TrackingGuidedInterpolation/Evaluation/results/vidvis3/',strcat(vn,'_WORSE.avi')))
       continue; 
    end
    out = VideoWriter(fullfile('/home/winston/workSpace/PycharmProjects/tracking/TrackingGuidedInterpolation/Evaluation/results/vidvis3/',strcat(vn,'.avi')));
    out.FrameRate = 25;
    open(out);
    OPTMOD  = '/home/winston/workSpace/PycharmProjects/tracking/TrackingGuidedInterpolation/Datasets/Original2/OTB100_optFlow/%s/';
    OptFNMod = '%04d_5.mat';
    GTFNMod  = '/home/winston/workSpace/PycharmProjects/tracking/TrackingGuidedInterpolation/Datasets/Original2/OTB100/%s/groundtruth_rect.txt';
    BASEMod = '/home/winston/workSpace/PycharmProjects/tracking/TrackingGuidedInterpolation/Datasets/Original2/OTB100/%s/img/';
    fr = dir(sprintf(BASEMod,vn));
	GTFN      = sprintf(GTFNMod,vn);
    load(GTFN);
    counter = 0;
    better = 0;
    start = -1;
	endd  = -1;
    for idxV = 1:N-1
        % in weirdlist and no content
        if ismember(vn,conf.weirdVideoList)
            tmp = conf.OriginalStartEndF(vn);
            start = tmp(1);
            endd  = tmp(2);
            if(idxV<start) || (idxV>endd)
                imgNextFn = fullfile(sprintf(BASEMod,vn),fr(idxV+3).name);
                imgNext = imread(imgNextFn);
                writeVideo(out, imgNext);
                continue;
            end
        end
        lastFrN = idxV;
        imgLastFn = fullfile(sprintf(BASEMod,vn),fr(idxV+2).name);
        imgNextFn = fullfile(sprintf(BASEMod,vn),fr(idxV+3).name);

        optLastFn = sprintf(OptFNMod,lastFrN);
    
        % imgLast
        imgLast = imread(imgLastFn);
        tmp = size(imgLast);
        w = tmp(1);
        h = tmp(2);
        % imgNext
        imgNext = imread(imgNextFn);
        load(fullfile(sprintf(OPTMOD,vn),optLastFn));
        % optLast
        optLast = optFlow;
        % gtBox
        if ~ismember(vn,conf.weirdVideoList)
            gtBox   = groundtruth_rect;
            lastGtBox = gtBox(lastFrN,:);
            nextGtBox = gtBox(lastFrN + 1,:);
            nextOptFBox  = optShiftRect(lastGtBox,optLast);
        else
            tt = size(gtBox);
            if (lastFrN + 1-start+1 > tt(1))
                writeVideo(out, nextCanvas);
               continue; 
            end
            
            gtBox   = groundtruth_rect;
            lastGtBox = gtBox(lastFrN-start+1,:);
            nextGtBox = gtBox(lastFrN + 1-start+1,:);
            nextOptFBox  = optShiftRect(lastGtBox,optLast);
        end
        


        optiou = IOU(nextGtBox,nextOptFBox);
        lastiou = IOU(lastGtBox,nextGtBox);
        
        nextCanvas = imgNext;
        nextCanvas = drawRect( nextCanvas, nextGtBox, 2,[255,0,0],'x1y1wh');
        nextCanvas = drawRect( nextCanvas, nextOptFBox, 2,[0,255,0],'x1y1wh');
        nextCanvas = drawRect( nextCanvas, lastGtBox, 2,[0,0,255],'x1y1wh');

        nextCanvas =insertText(nextCanvas,[90 30],['#' num2str(idxV+1)],'FontSize',16,'TextColor','red');
        nextCanvas =insertText(nextCanvas,[150 30],['OPT IOU:' sprintf('%.3f',optiou)],'FontSize',16,'TextColor','red');
        nextCanvas =insertText(nextCanvas,[280 30],['LAST IOU:' sprintf('%.3f',lastiou)],'FontSize',16,'TextColor','red');
        
        if lastiou == 0 && optiou==0
            z = 1;
        else
            counter  = counter + 1;
            if optiou > lastiou
                better = better + 1;
            end
        end
        if idxV > N - 10 % end 
             nextCanvas =insertText(nextCanvas,[410 30],['Opt better:' sprintf('%.3f\%',better/counter*100) ],'FontSize',16,'TextColor','blue');
        end
            
        
        
        
        
        writeVideo(out, nextCanvas);
    end
    close(out);
    if better/counter < 0.5
        % change name
        oldName = fullfile('/home/winston/workSpace/PycharmProjects/tracking/TrackingGuidedInterpolation/Evaluation/results/vidvis3/',strcat(vn,'.avi'));
        newName = [oldName(1:end - 4) '_WORSE.avi'];
        movefile(oldName,newName);
    end
    
        

    
    
end