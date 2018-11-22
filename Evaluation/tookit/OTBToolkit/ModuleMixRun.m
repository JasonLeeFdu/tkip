function [res,fps,choice] = ModuleMixRun(moduleName,imgSetOri,imgSetOriItp,init_rect,strategy)

% module configuration

MD_Ori = [];
MD_OriItp =[];
nFrames = length(imgSetOri);
res = zeros(nFrames,4);
res(1,:) = init_rect;
fps = 0;
Combine_OOIt = init_rect;
choice = 'O';
switch lower(moduleName)
    case 'vital'
        MD_Ori = VITAL_MODULE(imgSetOri,Combine_OOIt);
        MD_OriItp = VITAL_MODULE(imgSetOriItp,Combine_OOIt);  
    case 'strcf'
        MD_Ori = STRCF_MODULE(imgSetOri,Combine_OOIt);
        MD_OriItp = STRCF_MODULE(imgSetOriItp,Combine_OOIt);  
    case 'eco'
        MD_Ori = ECO_MODULE(imgSetOri,Combine_OOIt);
        MD_OriItp = ECO_MODULE(imgSetOriItp,Combine_OOIt);  
end
% core algorithms
tic
s = toc;
for t = 2:nFrames
   Res_O_t = MD_Ori.trackNext(imgSetOri{t},Combine_OOIt);
   Res_OI_t_05 = MD_OriItp.trackNext(imgSetOriItp{2*t -2},Combine_OOIt);
   Res_OI_t = MD_OriItp.trackNext(imgSetOriItp{2*t -1},Res_OI_t_05);
   % compare it with Combine_OOIt and get new Combine_OOIt to be the res of
   % time t
   img_t = imread(imgSetOri{t});
   Combine_OOIt = combinationStrategy(Res_O_t,Res_OI_t,Combine_OOIt,img_t,strategy);
   res(t,:) = Combine_OOIt; 
   if strayedMetric(Res_O_t,Combine_OOIt,img_t,strategy) < strayedMetric(Res_OI_t,Combine_OOIt, img_t,strategy)
        %fprintf('O');
        choice = [choice 'O'];
   else
        %fprintf('I');
        choice = [choice 'I'];
   end
   fprintf('.');
   if mod(t,30) == 0
       fprintf('\n');
       fprintf('%03d',floor(t));
   end
end
e = toc;
fps = (nFrames-1) / (e - s);
fprintf('\n\n');
end


function newCombination = combinationStrategy(OriThis,OriItpHThis,CombineLast,img_t,strategy)
%%%%%%% config
    switch strategy
        case 'IOU'
            if strayedMetric(OriThis,CombineLast,img_t,'IOU') > strayedMetric(OriItpHThis,CombineLast,img_t, 'IOU')
               % Ori is better
               newCombination = OriItpHThis;
            else
               %OriItpH is better
               newCombination = OriThis;
            end
        case 'LBP'
          	if strayedMetric(OriThis,CombineLast,img_t,'LBP') > strayedMetric(OriItpHThis,CombineLast,img_t, 'LBP')
               % Ori is better
               newCombination = OriItpHThis;
            else
               %OriItpH is better
               newCombination = OriThis;
            end
    end
end


function res = strayedMetric(thisRect,lastRect, img_t,method)% the bigger, the more strayed
    %% Let's assume that the rect is x1,y1,w,h
    [H,W] = size(img_t);
    switch method
        case 'IOU'
            res = 0-IOU(thisRect,lastRect);
        case 'LBP'
            thisRectXStart = min(max(1,thisRect(1)),W);
            thisRectXEnd   = min(max(1,thisRect(1) + thisRect(3) - 1),W);
            thisRectYStart = min(max(1,thisRect(2)),H);
            thisRectYEnd   = min(max(1,thisRect(2) + thisRect(4) - 1),H);
            
            lastRectXStart = min(max(1,lastRect(1)),W);
            lastRectXEnd   = min(max(1,lastRect(1) + lastRect(3) - 1),W);
            lastRectYStart = min(max(1,lastRect(2)),H);
            lastRectYEnd   = min(max(1,lastRect(2) + lastRect(4) - 1),H);
             
            imgThisCrop = img_t(thisRectYStart:thisRectYEnd,thisRectXStart:thisRectXEnd);
            imgLastCrop = img_t(lastRectYStart:lastRectYEnd,lastRectXStart:lastRectXEnd);
            thisLBPFeat = lbp(imgThisCrop);
            lastLBPFeat = lbp(imgLastCrop);
            res = pdist2(lastLBPFeat,thisLBPFeat);
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



