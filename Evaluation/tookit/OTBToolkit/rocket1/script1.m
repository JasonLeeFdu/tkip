newAlgPath = '/home/winston/workSpace/PycharmProjects/tracking/TrackingGuidedInterpolation/Evaluation/results/ComparativeTest/BothRects_Choose2Center';
oriAlgPath = '/home/winston/workSpace/PycharmProjects/tracking/TrackingGuidedInterpolation/Evaluation/results/trackingResults/Original/OTB100';

[IOU_AUC_Total_New,Pres_Med_Total_New,IOU_AUC_Mtrx_New,Pres_Med_Mtrx_New] = statisticResults(newAlgPath,'Adv');
[IOU_AUC_Total_Old,Pres_Med_Total_Old,IOU_AUC_Mtrx_Old,Pres_Med_Mtrx_Old] = statisticResults(oriAlgPath,'Ori');


Pres_Med_Mtrx_NO = reshape(Pres_Med_Mtrx_New - Pres_Med_Mtrx_Old,10,10);
IOU_AUC_Mtrx_No  = reshape(IOU_AUC_Mtrx_New  - IOU_AUC_Mtrx_Old,10,10);


show = IOU_AUC_Mtrx_No;

showAbs = abs(show); 
colormap = zeros(100,3);
fkCmlim = max(max(showAbs));
fuxiao = [0,0,1];
fuda   = [0,0,0];
zhengxiao = [1,0,0];
zhengda   = [1,1,0];
fu = linspace(0,1,50);fu = fu';
zheng = linspace(0,1,50)';zheng = zheng';
colormap(1:50,3) = fu;
colormap(51:end,1) = ones(50,1);
colormap(51:end,2) = zheng;

h = heatmap(show);
set(h,'ColorLimits',[-fkCmlim fkCmlim]);
set(h,'Colormap',colormap);



