function [res,fps,choice] = moduleMixRun1(moduleName,imgSetOri,imgSetOriItp,rect_anno,strategy)

% module configuration

MD_Ori = [];
MD_OriItp =[];
nFrames = length(imgSetOri);
init_rect = rect_anno(1,:);
res = zeros(nFrames,4);
res(1,:) = init_rect;
fps = 0;
Combine_OOIt = init_rect;

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
%%%%%%%% build choice1
choice = struct;
choice.O = init_rect;
choice.OI = init_rect;
choice.choice = 'O';
choice.lastChoice = init_rect;
choice.IOU_O = 1;
choice.IOU_OI = 1;
choice.IOU_ThisChoice = 'O';
choice.DLBP_O = 0;
choice.DLBP_OI = 0;
choice.DLBP_ThisChoice = 'O';




for t = 2:nFrames
   choiceT = struct;
   Res_O_t = MD_Ori.trackNext(imgSetOri{t},Combine_OOIt);
   Res_OI_t_05 = MD_OriItp.trackNext(imgSetOriItp{2*t -2},Combine_OOIt);
   Res_OI_t = MD_OriItp.trackNext(imgSetOriItp{2*t -1},Res_OI_t_05);
   choiceT.O = Res_O_t;
   choiceT.OI = Res_OI_t;
   choiceT.lastChoice = Combine_OOIt;
   % compare it with Combine_OOIt and get new Combine_OOIt to be the res of
   % time t
   
   img_t = imread(imgSetOri{t});
   img_t_1 =  imread(imgSetOri{t-1});
   [Combine_OOIt,O_IOU, OI_IOU,O_DLBP,OI_DLBP]  = combinationStrategy(Res_O_t,Res_OI_t,Combine_OOIt,img_t,img_t_1,strategy);
   res(t,:) = Combine_OOIt;  
   choiceT.IOU_O = O_IOU;
   choiceT.IOU_OI =OI_IOU;
   choiceT.DLBP_O = O_DLBP;
   choiceT.DLBP_OI = OI_DLBP;
 
   %% should call strayedMetric ,use this 
   %%  to speed it up.
   
    if O_DLBP <=  OI_DLBP
         choiceT.DLBP_ThisChoice = 'O';
    else
         choiceT.DLBP_ThisChoice = 'I';
    end
    
    if  -O_IOU <=   -OI_IOU
         choiceT.IOU_ThisChoice = 'O';
    else
         choiceT.IOU_ThisChoice = 'I';
    end
    
    if strcmp(strategy,'IOU')
       metricO = -O_IOU;
       metricIO = -OI_IOU;
         if metricO <=  metricIO
            choiceT.choice =  'O';
         else
            choiceT.choice =  'I';
        end
   elseif strcmp(strategy,'LBP')
       metricO = O_DLBP;
       metricIO = OI_DLBP;
         if metricO <=  metricIO
            choiceT.choice =  'O';
         else
            choiceT.choice =  'I';
        end
   end
  
   fprintf('.');
   if mod(t,30) == 0
       fprintf('\n');
       fprintf('%03d',floor(t));
   end
   choice(end+1) = choiceT;
   
end
e = toc;
fps = (nFrames-1) / (e - s);
fprintf('\n\n');
end


function [newCombination,O_IOU, OI_IOU,O_DLBP,OI_DLBP] = combinationStrategy(OriThis,OriItpHThis,CombineLast,img_t,img_t_1,strategy)
%%%%%%% config
    metricO_IOU = strayedMetric(OriThis,CombineLast,img_t,img_t_1,'IOU');
    metricOI_IOU = strayedMetric(OriItpHThis,CombineLast,img_t,img_t_1, 'IOU');
    O_DLBP = strayedMetric(OriThis,CombineLast,img_t,img_t_1,'LBP') ;
    OI_DLBP = strayedMetric(OriItpHThis,CombineLast,img_t, img_t_1,'LBP');
    switch strategy
        case 'IOU'
            if metricO_IOU > metricOI_IOU
               % Ori is better
               newCombination = OriItpHThis;
            else
               %OriItpH is better
               newCombination = OriThis;
            end
        case 'LBP'
          	if O_DLBP > OI_DLBP
               % Ori is better
               newCombination = OriItpHThis;
            else
               %OriItpH is better
               newCombination = OriThis;
            end
    end
    O_IOU = abs(metricO_IOU);
    OI_IOU = abs(metricOI_IOU);
    
end


function res = strayedMetric(thisRect,lastRect, img_t, img_t_1 ,method)% the bigger, the more strayed
    %% Let's assume that the rect is x1,y1,w,h
    [H,W] = size(img_t);
    switch method
        case 'IOU'
            res = 0-IOU(thisRect,lastRect);
        case 'LBP'
            res = LBP (thisRect,lastRect, img_t, img_t_1 );
    end

end


function res =  LBP (thisRect,lastRect, img_t, img_t_1 )
           W = size(img_t,2);
           H = size(img_t,1);
            thisRectXStart = min(max(1,thisRect(1)),W);
            thisRectXEnd   = min(max(1,thisRect(1) + thisRect(3) - 1),W);
            thisRectYStart = min(max(1,thisRect(2)),H);
            thisRectYEnd   = min(max(1,thisRect(2) + thisRect(4) - 1),H);
            
            lastRectXStart = min(max(1,lastRect(1)),W);
            lastRectXEnd   = min(max(1,lastRect(1) + lastRect(3) - 1),W);
            lastRectYStart = min(max(1,lastRect(2)),H);
            lastRectYEnd   = min(max(1,lastRect(2) + lastRect(4) - 1),H);
          	
            imgThisCrop = img_t(thisRectYStart:thisRectYEnd,thisRectXStart:thisRectXEnd,:);
            imgLastCrop = img_t_1(lastRectYStart:lastRectYEnd,lastRectXStart:lastRectXEnd,:);
            if size(imgThisCrop,3) == 3
               imgThisCropGray = rgb2gray(imgThisCrop); 
            else
                imgThisCropGray = imgThisCrop;
            end
            
        	if size(imgThisCrop,3) == 3
               imgLastCropGray = rgb2gray(imgLastCrop);
            else
               imgLastCropGray = imgLastCrop;
            end

            
            thisLBPFeat = lbp(imgThisCropGray);
            lastLBPFeat = lbp(imgLastCropGray);
            res = pdist2(lastLBPFeat,thisLBPFeat);
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

