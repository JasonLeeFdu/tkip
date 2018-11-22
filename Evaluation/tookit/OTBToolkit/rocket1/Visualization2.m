function Visualization2(choice,imgSet, bundleRes,outputPath,append)
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
            frame = drawRect( frame,OriginAnno(i,:), 2, [255 0 0] ,'x1y1wh');
            frame = drawRect( frame,OriginRes(i,:), 2, [0 0 0] ,'x1y1wh');
            frame = drawRect( frame,OriginalInterpRes(i,:), 2, [255 127 39] ,'x1y1wh'); 
        else   
            if i >= append(1) && i <= append(2)
                frame = drawRect( frame,OriginAnno(i- append(1)+1,:), 2, [255 0 0] ,'x1y1wh');
                frame = drawRect( frame,OriginRes(i- append(1)+1,:), 2, [0 0 0] ,'x1y1wh');
                frame = drawRect( frame,OriginalInterpRes(i- append(1)+1,:), 2, [255 127 39] ,'x1y1wh'); 
            end
        end
        % get tag
        if all(append==-1)
                    %
                    frame =insertText(frame,[30 30],'I','FontSize',16,'TextColor','red' ,'BoxOpacity',0.0);
                    frame =insertText(frame,[90 30],['#' num2str(i)],'FontSize',16,'TextColor','red','BoxOpacity',0.0);
             
           
        else
            if i >= append(1) && i <= append(2)
              
                  
                    frame =insertText(frame,[90 30],['#' num2str(i)],'FontSize',16,'TextColor','red','BoxOpacity',0.0);
            
                  
            end
        end
        
        
        writeVideo(out, frame);
    end
    close(out);
end