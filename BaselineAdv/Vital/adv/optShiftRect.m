function [newRect] = optShiftRect(rect,optFlow)
optX1 = optFlow(max(1,rect(2)):min(size(optFlow,1),rect(2)+rect(4)-1),max(1,rect(1)):min(size(optFlow,2),rect(1)+rect(3)-1),1);
optY1 = optFlow(max(1,rect(2)):min(size(optFlow,1),rect(2)+rect(4)-1),max(1,rect(1)):min(size(optFlow,2),rect(1)+rect(3)-1),2);
[h,w,c] = size(optFlow);
deltaX = mean(mean(optX1))*w;
deltaY = mean(mean(optY1))*h;
newRect = rect;
newRect(1) = round(rect(1) + deltaX);
newRect(2) = round(rect(2) + deltaY);

end


%%
% 
% img1 = '/home/winston/workSpace/PycharmProjects/tracking/TrackingGuidedInterpolation/Datasets/Original/OTB100/Box/img/0026.jpg';
% img2 = '/home/winston/workSpace/PycharmProjects/tracking/TrackingGuidedInterpolation/Datasets/Original/OTB100/Box/img/0027.jpg';
% name = '/home/winston/workSpace/PycharmProjects/tracking/TrackingGuidedInterpolation/Datasets/Original/OTB100_optFlow/Box/0026_5.mat';
% name1 = '/home/winston/workSpace/PycharmProjects/tracking/TrackingGuidedInterpolation/Datasets/Original/OTB100/Box/groundtruth_rect.txt';
% load(name);
% gt = load(name1);
% gtBox1 = gt(26,:);
% gtBox2 = gt(27,:);
% rect = gtBox1;
% 

% optX1 = optFlow(max(1,rect(2)):min(size(optFlow,1),rect(2)+rect(4)-1),max(1,rect(1)):min(size(optFlow,2),rect(1)+rect(3)-1),1);
% optY1 = optFlow(max(1,rect(2)):min(size(optFlow,1),rect(2)+rect(4)-1),max(1,rect(1)):min(size(optFlow,2),rect(1)+rect(3)-1),2);
% [h,w,c] = size(optFlow);
% 
% deltaX = mean(mean(optX1))*w;
% deltaY = mean(mean(optY1))*h;
% 
% 
% 
% 
% 
%%



