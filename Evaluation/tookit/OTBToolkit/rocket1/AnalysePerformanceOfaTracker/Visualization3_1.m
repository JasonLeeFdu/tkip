function fatalFlag = Visualization3_1(InterpBbox,imgSet, imgSetInterp, bundleRes,outputPath,append,statistics)
% for one single video clip
    OriginAnno= bundleRes(:,:,1);
    OriginRes = bundleRes(:,:,2);
    OriginalInterpRes= bundleRes(:,:,3);
    out = VideoWriter(outputPath);
    out.FrameRate = 50;
    out.Quality = 95;
    open(out);
    resCounter = 1;
    resInterpCounter = 1;
    protoCanvas = uint8(zeros(620,820,3));
    protoD      = uint8(zeros(300,400,3));
    ah = 1:300;aw = 1:400;
    bh = 1:300;bw = 421:820;
    ch = 321:620;cw = 1:400;
    dh = 321:620;dw = 421:820;
    targetShape = [300,400];
    fontSize = 24;
    fontPosition = [20 30];  
    nRects = size(OriginAnno,1);
    IOU_ADV_GT_List = [];
    IOU_ORI_GT_List = [];
    FATAL_AVD_List = [];
    FATAL_ORI_List = [];
    IOU_ADV_GT_List(end+1) = 1;
    IOU_ORI_GT_List(end+1) = 1;
    
    
    
    i=1;
    %%%$$$ A-1
    thisA = imread(imgSet{1});
    if all(append ==-1)
        %正常视频 
        thisA = drawRect( thisA,OriginAnno(1,:), 2, [255 0 0] ,'x1y1wh');
        thisA = drawRect( thisA,OriginRes(1,:), 2, [0 0 0] ,'x1y1wh');
        thisA = drawRect( thisA,OriginalInterpRes(1,:), 2, [255 127 39] ,'x1y1wh');             
    else
        %异常视频
        if i >= append(1) && i <= append(2)
            % 异常视频有框的帧
            thisA = drawRect( thisA,OriginAnno(1,:), 2, [255 0 0] ,'x1y1wh');
            thisA = drawRect( thisA,OriginRes(1,:), 2, [0 0 0] ,'x1y1wh');
            thisA = drawRect( thisA,OriginalInterpRes(1,:), 2, [255 127 39] ,'x1y1wh'); 
        end
    end
    %%%$$$ B-1
    thisB = thisA;
    if all(append ==-1)
        %正常视频 
        thisB = drawRect( thisB,OriginAnno(1,:), 2, [255 0 0] ,'x1y1wh');
        thisB = drawRect( thisB,InterpBbox(1,:), 2, [0 0 255] ,'x1y1wh'); 
        
    else
        %异常视频
        if i >= append(1) && i <= append(2)
            % 异常视频有框的帧 此时对下标有一个清晰的换算
            virtualI = i - append(1) + 1;
            posInterp = virtualI*2-1;
            thisB = drawRect( thisB,OriginAnno(1,:), 2, [255 0 0] ,'x1y1wh');
            thisB = drawRect( thisB,InterpBbox(1,:), 2, [0 0 255] ,'x1y1wh'); 
        end
    end
    %%%$$$ C-1
    thisC = imread(imgSet{1});
    if all(append ==-1)
        %正常视频 
        thisC = drawRect( thisC,OriginAnno(i,:), 2, [255 127 39] ,'x1y1wh');
        thisC = drawRect( thisC,OriginRes(i,:), 2, [0 0 0] ,'x1y1wh');
    else
        %异常视频
        if i >= append(1) && i <= append(2)
            % 异常视频有框的帧,此时对下标有一个清晰的换算
            virtualI =  i - append(1) + 1;
            thisC = drawRect( thisC,OriginAnno(virtualI,:), 2, [255 127 39] ,'x1y1wh');
            thisC = drawRect( thisC,OriginRes(virtualI,:), 2, [0 0 0] ,'x1y1wh');
        else 
            % 异常视频，什么也没有的帧
        end
    end       

    
    %%%$$$ D-1
    thisD = drawNumberSubcanvas(protoD,IOU_ADV_GT_List(1),IOU_ORI_GT_List(1),FATAL_AVD_List,FATAL_ORI_List,[]);
    frame = protoCanvas;
    thisA = imresize(thisA,targetShape);
    thisB = imresize(thisB,targetShape);
    thisC = imresize(thisC,targetShape); 
    thisA = insertText(thisA,fontPosition,['#' num2str(1)],'FontSize',fontSize,'TextColor','red','BoxOpacity',0.0);
    thisC = insertText(thisC,fontPosition,['#' num2str(1)],'FontSize',fontSize,'TextColor','red','BoxOpacity',0.0);     
    thisB = insertText(thisB,fontPosition,['#' num2str(1)],'FontSize',fontSize,'TextColor','red','BoxOpacity',0.0);  
    frame(ah,aw,:) = thisA;frame(bh,bw,:) = thisB;frame(ch,cw,:) = thisC;frame(dh,dw,:) = thisD;
    writeVideo(out, frame);
    
    for i = 2:length(imgSet)
        
        % 信息提示
        if mod(i,55) == 0
            fprintf('%.3f\n ',i*100/length(imgSet));
        end        
       
        %%%%            OriginalInterpRes IS NOTTT InterpBbox  !!!!!!!!!!!!!!
        
        
        %%%$$$%%%$$$%%%$$$%%%$$$%%%$$$ A -- tracking 总结果,frame copy
        thisA = imread(imgSet{i});
        lastA = imread(imgSet{i-1});
        
        if all(append ==-1)
            %正常视频 
            thisA = drawRect( thisA,OriginAnno(i,:), 2, [255 0 0] ,'x1y1wh');
            thisA = drawRect( thisA,OriginRes(i,:), 2, [0 0 0] ,'x1y1wh');
            thisA = drawRect( thisA,OriginalInterpRes(i,:), 2, [255 127 39] ,'x1y1wh');             
            lastA = drawRect( lastA,OriginAnno(i-1,:), 2, [255 0 0] ,'x1y1wh');
            lastA = drawRect( lastA,OriginRes(i-1,:), 2, [0 0 0] ,'x1y1wh');
            lastA = drawRect( lastA,OriginalInterpRes(i-1,:), 2, [255 127 39] ,'x1y1wh');      
        else
            %异常视频
            if i >= append(1) && i <= append(2)
                % 异常视频有框的帧
                thisA = drawRect( thisA,OriginAnno(i- append(1)+1,:), 2, [255 0 0] ,'x1y1wh');
                thisA = drawRect( thisA,OriginRes(i- append(1)+1,:), 2, [0 0 0] ,'x1y1wh');
                thisA = drawRect( thisA,OriginalInterpRes(i- append(1)+1,:), 2, [255 127 39] ,'x1y1wh'); 
                if i- append(1)+1 >1
                    lastA = drawRect( lastA,OriginAnno(i- append(1),:), 2, [255 0 0] ,'x1y1wh');
                    lastA = drawRect( lastA,OriginRes(i- append(1),:), 2, [0 0 0] ,'x1y1wh');
                    lastA = drawRect( lastA,OriginalInterpRes(i- append(1),:), 2, [255 127 39] ,'x1y1wh'); 
                end
            else
                % 异常视频，什么也没有的帧
                if  i >= append(1) && i- append(1) <= append(2)
                end
            end
        end
       
       
        %%%$$$%%%$$$%%%$$$%%%$$$%%%$$$ B - 插帧结果，双倍帧率，前后帧不一样
        posInterp = 2*i -1; % used for drawing the rect
        thisB = imread(imgSetInterp{posInterp});
        lastB = imread(imgSetInterp{posInterp-1});
        if all(append ==-1)
            %正常视频 
            posInterp = i*2-1;
            thisB = drawRect( thisB,OriginAnno(i,:), 2, [255 0 0] ,'x1y1wh');
            thisB = drawRect( thisB,InterpBbox(posInterp,:), 2, [255 127 39] ,'x1y1wh');      
            lastB = drawRect( lastB,InterpBbox(posInterp-1,:),2, [0 0 255] ,'x1y1wh');   
        else
            %异常视频
            if i >= append(1) && i <= append(2)
                % 异常视频有框的帧 此时对下标有一个清晰的换算
                virtualI = i - append(1) + 1;
                posInterp = virtualI*2-1;
               
                thisB = drawRect( thisB,OriginAnno(virtualI,:), 2, [255 0 0] ,'x1y1wh');
                thisB = drawRect( thisB,InterpBbox(posInterp,:), 2, [0 0 255] ,'x1y1wh'); 
                if virtualI > 1
                    lastB = drawRect( lastB,InterpBbox(posInterp-1,:),2, [0 0 255] ,'x1y1wh'); 
                end
            else 
               
               % 异常视频，什么也没有的帧
            end
        end
        %%%$$$%%%$$$%%%$$$%%%$$$%%%$$$ C - 原始算法的结果
        thisC = imread(imgSet{i});
        lastC = imread(imgSet{i-1});
        if all(append ==-1)
            %正常视频 
            thisC = drawRect( thisC,OriginAnno(i,:), 2, [255 0 0] ,'x1y1wh');
            thisC = drawRect( thisC,OriginRes(i,:), 2, [0 0 0] ,'x1y1wh');
            lastC = drawRect( lastC,OriginAnno(i-1,:), 2, [255 0 0] ,'x1y1wh');
            lastC = drawRect( lastC,OriginRes(i-1,:), 2, [0 0 0] ,'x1y1wh');
        else
            %异常视频
            if i >= append(1) && i <= append(2)
                % 异常视频有框的帧,此时对下标有一个清晰的换算
                virtualI =  i - append(1) + 1;
                thisC = drawRect( thisC,OriginAnno(virtualI,:), 2, [255 0 0] ,'x1y1wh');
                thisC = drawRect( thisC,OriginRes(virtualI,:), 2, [0 0 0] ,'x1y1wh');
                if virtualI > 1
                    lastC = drawRect( lastC,OriginAnno(virtualI-1,:), 2, [255 0 0] ,'x1y1wh');
                    lastC = drawRect( lastC,OriginRes(virtualI-1,:), 2, [0 0 0] ,'x1y1wh');
                end
            else 
                % 异常视频，什么也没有的帧
            end
        	
        end       

        %%%$$$ caculate D and write D 
        thisD = protoD;
        lastD = protoD;
        if nRects - i <= 50
               stt = statistics;
            else
               stt = [];
        end
        %%% calculate IOU and get them printed
        if all(append ==-1)
            %正常视频 
            
            %IOU_ADV_GT_List 计算
            posInterp = i*2-1;
            IOUAdvLast = -1;
            IOUAdvThis = IOU(OriginAnno(i,:),OriginalInterpRes(i,:));
            IOUOriThis = IOU(OriginAnno(i,:),OriginRes(i,:));
            IOU_ADV_GT_List(end+1) = IOUAdvThis;
            IOU_ORI_GT_List(end+1) = IOUOriThis;
            %FATAL_AVD_List 计算
            if IOUOriThis <= 0.001 && IOU_ORI_GT_List(i-1)>0.001 
                FATAL_ORI_List(end+1) = i;
            end
            if IOUAdvThis <= 0.001 && IOU_ADV_GT_List(i-1)>0.001 
                FATAL_AVD_List(end+1) = i;
            end
            thisD = drawNumberSubcanvas(thisD,IOUAdvThis,IOUOriThis,FATAL_AVD_List,FATAL_ORI_List,stt);
            lastD = drawNumberSubcanvas(lastD,-1,IOU_ORI_GT_List(i-1),FATAL_AVD_List,FATAL_ORI_List,stt);
            
        else
            %异常视频
            if i >= append(1) && i <= append(2)
               % 异常视频有框的帧 此时对下标有一个清晰的换算
                virtualI = i - append(1) + 1;
                posInterp = virtualI*2-1;
                IOUAdvLast = -1;
                IOUAdvThis = IOU(OriginAnno(virtualI,:),OriginalInterpRes(virtualI,:));
                IOUOriThis = IOU(OriginAnno(virtualI,:),OriginRes(virtualI,:));
                IOU_ADV_GT_List(end+1) = IOUAdvThis;
                IOU_ORI_GT_List(end+1) = IOUOriThis;
                %FATAL_AVD_List 计算
                if IOUOriThis <= 0.001 && IOU_ORI_GT_List(i-1)>0.001 
                    FATAL_ORI_List(end+1) = i;
                end
                if IOUAdvThis <= 0.001 && IOU_ADV_GT_List(virtualI-1)>0.001
                    FATAL_AVD_List(end+1) = i;
                end
                thisD = drawNumberSubcanvas(thisD,IOUAdvThis,IOUOriThis,FATAL_AVD_List,FATAL_ORI_List,stt);
                if virtualI >1
                    lastD = drawNumberSubcanvas(lastD,-1,IOU_ORI_GT_List(virtualI-1),FATAL_AVD_List,FATAL_ORI_List,stt);
                else
                    lastD = drawNumberSubcanvas(thisD,[],[],FATAL_AVD_List,FATAL_ORI_List,stt);
                end
            else 
                % 异常视频，什么也没有的帧
                virtualI = i - append(1) + 1;
                lastD = drawNumberSubcanvas(lastD,[],[],FATAL_AVD_List,FATAL_ORI_List,stt);
                thisD = drawNumberSubcanvas(thisD,[],[],FATAL_AVD_List,FATAL_ORI_List,stt);
            end
        end
        % resize and put ABC on canvas and 
        lastFrame = protoCanvas;
        thisFrame = protoCanvas;
        thisA = imresize(thisA,targetShape);lastA = imresize(lastA,targetShape);
        thisB = imresize(thisB,targetShape);lastB = imresize(lastB,targetShape);
        thisC = imresize(thisC,targetShape);lastC = imresize(lastC,targetShape);
        
        
           
        thisA =insertText(thisA,fontPosition,['#' num2str(i)],'FontSize',fontSize,'TextColor','red','BoxOpacity',0.0);
        lastA =insertText(lastA,fontPosition,['#' num2str(i-1)],'FontSize',fontSize,'TextColor','red','BoxOpacity',0.0);
        thisB = insertText(thisB,fontPosition,['#' num2str(i)],'FontSize',fontSize,'TextColor','red','BoxOpacity',0.0);
        lastB = insertText(lastB,fontPosition,['#' num2str(i-0.5)],'FontSize',fontSize,'TextColor','red','BoxOpacity',0.0);
        thisC = insertText(thisC,fontPosition,['#' num2str(i)],'FontSize',fontSize,'TextColor','red','BoxOpacity',0.0);
        lastC = insertText(lastC,fontPosition,['#' num2str(i-1)],'FontSize',fontSize,'TextColor','red','BoxOpacity',0.0);        
        
        lastFrame(ah,aw,:) = lastA;lastFrame(bh,bw,:) = lastB;lastFrame(ch,cw,:) = lastC;lastFrame(dh,dw,:) = lastD;
        thisFrame(ah,aw,:) = thisA;thisFrame(bh,bw,:) = thisB;thisFrame(ch,cw,:) = thisC;thisFrame(dh,dw,:) = thisD;
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
       
        
        %%%%%%%%%%%%%          此处模板                %%%%%%%%%%%%%%%%%%%%%
%         if all(append ==-1)
%             %正常视频 
%            
%         else
%             %异常视频
%             if i >= append(1) && i <= append(2)
%                 % 异常视频有框的帧,此时对下标有一个清晰的换算
%             else 
%                 % 异常视频，什么也没有的帧
%             end
%         end
        %%%%%%%%%%%%%          此处模板  结束          %%%%%%%%%%%%%%%%%%%%%%
      
        writeVideo(out, lastFrame);
        writeVideo(out, thisFrame);
    end
    close(out);
    
    if ~isempty(FATAL_AVD_List)
        fatalFlag = true;
    else
        fatalFlag = false;
    end
    
    if ~isempty(FATAL_ORI_List)
        fatalFlag = fatalFlag || true;
    else
        fatalFlag = fatalFlag ||false;
    end
end



function protoD = drawNumberSubcanvas(protoD,IOU_ADV_GT,IOU_ORI_GT,FATAL_AVD_List,FATAL_ORI_List,statistics)
    MAX_LIST_DISP_LENTH = 7;
    protoD = insertText(protoD,[20 20],['IOU_ADV&GT'],'FontSize',18,'TextColor','white','BoxOpacity',0.0);
    protoD = insertText(protoD,[20 40],['IOU_ORI&GT'],'FontSize',18,'TextColor','white','BoxOpacity',0.0);
    protoD = insertText(protoD,[20 70],['FATAL ADV'],'FontSize',18,'TextColor','white','BoxOpacity',0.0);
    protoD = insertText(protoD,[20 140],['FATAL ORI'],'FontSize',18,'TextColor','white','BoxOpacity',0.0);
        
    while length(FATAL_AVD_List) > MAX_LIST_DISP_LENTH
        FATAL_AVD_List(1) = [];        
    end
    while length(FATAL_ORI_List) > MAX_LIST_DISP_LENTH
        FATAL_ORI_List(1) = [];        
    end    
    if IOU_ADV_GT ~= -1
       if IOU_ADV_GT > IOU_ORI_GT
           protoD = insertText(protoD,[300 20],['better'],'FontSize',18,'TextColor','green','BoxOpacity',0.0);
       elseif IOU_ADV_GT < IOU_ORI_GT
           protoD = insertText(protoD,[300 40],['better'],'FontSize',18,'TextColor','green','BoxOpacity',0.0);
       end
    end   
    protoD = insertText(protoD,[200 20],num2str(IOU_ADV_GT),'FontSize',18,'TextColor','white','BoxOpacity',0.0);
    protoD = insertText(protoD,[200 40],num2str(IOU_ORI_GT),'FontSize',18,'TextColor','white','BoxOpacity',0.0);
    protoD = insertText(protoD,[30 100],num2str(FATAL_AVD_List),'FontSize',18,'TextColor','yellow','BoxOpacity',0.0);
    protoD = insertText(protoD,[30 170],num2str(FATAL_ORI_List),'FontSize',18,'TextColor','yellow','BoxOpacity',0.0);
    
    if ~isempty(statistics)
        protoD = insertText(protoD,[20 200],'IOU_AUC Adv:','FontSize',18,'TextColor','white','BoxOpacity',0.0);
        protoD = insertText(protoD,[170 200],num2str(statistics(1)),'FontSize',18,'TextColor','red','BoxOpacity',0.0);
        protoD = insertText(protoD,[20 230],'IOU_AUC Ori:','FontSize',18,'TextColor','white','BoxOpacity',0.0);
        protoD = insertText(protoD,[170 230],num2str(statistics(2)),'FontSize',18,'TextColor','red','BoxOpacity',0.0);
    end
   
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

