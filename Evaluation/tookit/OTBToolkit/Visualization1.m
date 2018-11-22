function Visualization1(choice,imgSet, bundleRes,outputPath,append)
    global additionalNameTag
    OriginAnno= bundleRes(:,:,1);
    OriginRes = bundleRes(:,:,2);
    OriginalInterpRes= bundleRes(:,:,3);
    out = VideoWriter(outputPath);
    out.FrameRate = 25;
    open(out);
    for i = 1:length(imgSet)
        if mod(i,55) == 0
            fprintf('%.3f\n ',i*100/length(imgSet));
        end        
        frame = imread(imgSet{i});
        if all(append ==-1)
            frame = drawRect( frame,OriginAnno(i,:), 1, [255 0 0] ,'x1y1wh');
            frame = drawRect( frame,OriginRes(i,:), 1, [0 0 0] ,'x1y1wh');
            frame = drawRect( frame,OriginalInterpRes(i,:), 1, [255 255 255] ,'x1y1wh'); 
            frame = drawRect( frame,choice(i).O, 1, [255 255 0] ,'x1y1wh'); 
            frame = drawRect( frame,choice(i).OI, 1, [0 0 255] ,'x1y1wh'); 
            frame = drawRect( frame,choice(i).lastChoice, 1, [180 127 135] ,'x1y1wh'); 
            
        else   
            if i >= append(1) && i <= append(2)
                frame = drawRect( frame,OriginAnno(i- append(1)+1,:), 1, [255 0 0] ,'x1y1wh');
                frame = drawRect( frame,OriginRes(i- append(1)+1,:), 1, [0 0 0] ,'x1y1wh');
                frame = drawRect( frame,OriginalInterpRes(i- append(1)+1,:), 1, [255 255 255] ,'x1y1wh'); 
                frame = drawRect( frame,choice(i- append(1)+1).O, 1, [255 255 0] ,'x1y1wh'); 
                frame = drawRect( frame,choice(i- append(1)+1).OI, 1, [0 0 255] ,'x1y1wh'); 
                frame = drawRect( frame,choice(i- append(1)+1).lastChoice, 1, [180 127 135] ,'x1y1wh'); 
            end
        end
        
        % get tag
        if all(append==-1)
          
                if strcmp(choice(i).choice,'O')
                    % 
                    frame = insertText(frame,[30 30],'O','FontSize',16,'TextColor','red');
                    frame =insertText(frame,[90 30],['#' num2str(i)],'FontSize',16,'TextColor','red');
                else
                    %
                    frame =insertText(frame,[30 30],'I','FontSize',16,'TextColor','red');
                    frame =insertText(frame,[90 30],['#' num2str(i)],'FontSize',16,'TextColor','red');
                end
        else
            if i >= append(1) && i <= append(2)
                if strcmp(choice(i-append(1)+1),'O')
                    % 
                    frame =insertText(frame,[30 30],'O','FontSize',16,'TextColor','red');
                    frame =insertText(frame,[90 30],['#' num2str(i)],'FontSize',16,'TextColor','red');
                else
                    %
                    frame =insertText(frame,[30 30],'I','FontSize',16,'TextColor','red');
                    frame =insertText(frame,[90 30],['#' num2str(i)],'FontSize',16,'TextColor','red');
                end
            end
        end
        
        
         % get tag
        
        if all(append==-1)
            % Normal
            thisImg = imread(imgSet{i});
            lastImg = imread(imgSet{max(i-1,1)});

            if i == 72
               z = 1; 
            end
            
            if length(size(thisImg)) == 3
                [h,w,xx] = size(thisImg);
            else
                [h,w] = size(thisImg);
                thisImg = repmat(thisImg,[1,1,3]);
                lastImg = repmat(lastImg,[1,1,3]);
            end
            

            thisGT= OriginAnno(i,:);
            thisGT = thisImg(min(max(1,thisGT(2)),h):min(max(1,thisGT(2)+thisGT(4)-1),h),min(max(1,thisGT(1)),w):min(max(1,thisGT(1)+thisGT(3)-1),w),:);
            thisLast = choice(i).lastChoice;
            thisLast = lastImg(min(max(1,thisLast(2)),h):min(max(1,thisLast(2)+thisLast(4)-1),h),min(max(1,thisLast(1)),w):min(max(1,thisLast(1)+thisLast(3)-1),w),:);
            if strcmp(choice(i).choice,'O')
                thisThis = choice.O;
                thisThis = thisImg(min(max(1,thisThis(2)),h):min(max(1,thisThis(2)+thisThis(4)-1),h),min(max(1,thisThis(1)),w):min(max(1,thisThis(1)+thisThis(3)-1),w),:);
            else
                thisThis = choice.OI;
                thisThis = thisImg(min(max(1,thisThis(2)),h):min(max(1,thisThis(2)+thisThis(4)-1),h),min(max(1,thisThis(1)),w):min(max(1,thisThis(1)+thisThis(3)-1),w),:);
            end
            if i == 273
                aa = 1;
            end
            thisO = choice(i).O ;
            thisO = thisImg(min(max(1,thisO(2)),h):min(max(1,thisO(2)+thisO(4)-1),h),min(max(1,thisO(1)),w):min(max(1,thisO(1)+thisO(3)-1),w),:);
            thisOI =  choice(i).OI;
            thisOI = thisImg(min(max(1,thisOI(2)),h):min(max(1,thisOI(2)+thisOI(4)-1),h),min(max(1,thisOI(1)),w):min(max(1,thisOI(1)+thisOI(3)-1),w),:);
            if strcmp(choice(i).choice,'O')
                thisThis = thisO;
            else
                thisThis = thisOI;
            end
            IOU_O = choice(i).IOU_O;
            IOU_OI = choice(i).IOU_OI;
            DIST_LBP_O = choice(i).DLBP_O;
            DIST_LBP_OI  = choice(i).DLBP_OI;
            if strcmp(additionalNameTag,'LBP')
                thisChoice = choice(i).DLBP_ThisChoice;
            else
                thisChoice = choice(i).IOU_ThisChoice;
            end
            framePos = i;
            thisGTRect = OriginAnno(i,:);
            IOU_O_GT = IOU(thisGTRect,choice(i).O);
            IOU_OI_GT = IOU(thisGTRect,choice(i).OI);
            canvas = paintOnCanvas(frame,thisGTRect,thisGT,thisThis,thisLast,thisO,thisOI,IOU_O,IOU_OI,IOU_O_GT,IOU_OI_GT,DIST_LBP_O,DIST_LBP_OI,thisChoice,framePos);

        else
            %weird
          	if i >= append(1) && i <= append(2)
                % weird - have 
                i = i - append(1) + 1;
                thisImg = imread(imgSet{i});
                lastImg = imread(imgSet{max(i-1,1)});
                if i == 72
                   z = 1; 
                end
                

                if length(size(thisImg)) == 3
                    [h,w,xx] = size(thisImg);
                else
                    [h,w] = size(thisImg);
                    thisImg = repmat(thisImg,[1,1,3]);
                    lastImg = repmat(lastImg,[1,1,3]);
                end
           
                thisGT= OriginAnno(i,:);
                thisGT = thisImg(min(max(1,thisGT(2)),h):min(max(1,thisGT(2)+thisGT(4)-1),h),min(max(1,thisGT(1)),w):min(max(1,thisGT(1)+thisGT(3)-1),w),:);
                thisLast = choice(i).lastChoice;
                thisLast = lastImg(min(max(1,thisLast(2)),h):min(max(1,thisLast(2)+thisLast(4)-1),h),min(max(1,thisLast(1)),w):min(max(1,thisLast(1)+thisLast(3)-1),w),:);
                if strcmp(choice(i).choice,'O')
                    thisThis = choice.O;
                    thisThis = thisImg(min(max(1,thisThis(2)),h):min(max(1,thisThis(2)+thisThis(4)-1),h),min(max(1,thisThis(1)),w):min(max(1,thisThis(1)+thisThis(3)-1),w),:);
                else
                    thisThis = choice.OI;
                    thisThis = thisImg(min(max(1,thisThis(2)),h):min(max(1,thisThis(2)+thisThis(4)-1),h),min(max(1,thisThis(1)),w):min(max(1,thisThis(1)+thisThis(3)-1),w),:);
                end

                thisO = choice(i).O ;
                thisO = thisImg(min(max(1,thisO(2)),h):min(max(1,thisO(2)+thisO(4)-1),h),min(max(1,thisO(1)),w):min(max(1,thisO(1)+thisO(3)-1),w),:);
                thisOI =  choice(i).OI;
                thisOI = thisImg(min(max(1,thisOI(2)),h):min(max(1,thisOI(2)+thisOI(4)-1),h),min(max(1,thisOI(1)),w):min(max(1,thisOI(1)+thisOI(3)-1),w),:);
                if strcmp(choice(i).choice,'O')
                    thisThis = thisO;
                else
                    thisThis = thisOI;
                end
                IOU_O = choice(i).IOU_O;
                IOU_OI = choice(i).IOU_OI;
                DIST_LBP_O = choice(i).DLBP_O;
                DIST_LBP_OI  = choice(i).DLBP_OI;
                if strcmp(additionalNameTag,'LBP')
                    thisChoice = choice(i).DLBP_ThisChoice;
                else
                    thisChoice = choice(i).IOU_ThisChoice;
                end
                framePos = i;
                thisGTRect = OriginAnno(i,:);
                IOU_O_GT = IOU(thisGTRect,choice(i).O);
                IOU_OI_GT = IOU(thisGTRect,choice(i).OI);
                canvas = paintOnCanvas(frame,thisGTRect,thisGT,thisThis,thisLast,thisO,thisOI,IOU_O,IOU_OI,IOU_O_GT,IOU_OI_GT,DIST_LBP_O,DIST_LBP_OI,thisChoice,framePos);
            else
                % weird - blank
                if length(size(frame)) == 2
                    frame = repmat(frame,[1,1,3]);
                end               
                canvas = paintOnCanvasBlank(frame,i);               
            end
                
        end
        
        writeVideo(out, canvas);
    end
    close(out);
end


function overlap = IOU (rect1,rect2) % lefttop widh height
leftA = rect1(:,1);
bottomA = rect1(:,2);
rightA = leftA + rect1(:,3) - 1;
topA = bottomA + rect1(:,4) - 1;
leftB = rect2(:,1);
bottomB = rect2(:,2);
rightB = leftB + rect2(:,3) - 1;
topB = bottomB + rect2(:,4) - 1;

tmp = (max(0, min(rightA, rightB) - max(leftA, leftB)+1 )) .* (max(0, min(topA, topB) - max(bottomA, bottomB)+1 ));
areaA = rect1(:,3) .* rect1(:,4);
areaB = rect2(:,3) .* rect2(:,4);
overlap = tmp./(areaA+areaB-tmp);
end



