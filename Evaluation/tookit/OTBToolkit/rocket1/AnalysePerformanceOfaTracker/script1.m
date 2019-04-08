resPath = '/home/winston/workSpace/PycharmProjects/tracking/TrackingGuidedInterpolation/Evaluation/results/trackingResults/stateoftheart/OTB100';

[~,~,IOU_AUC_SiamRPNpp,Pres_Med_SiamRPNpp] = evaluateSequenceAUC(resPath,'SiamRPN++');
[~,~,IOU_AUC_JROTM,Pres_Med_JROTM] = evaluateSequenceAUC(resPath,'VITAL_Adv');
[~,~,IOU_AUC_VITAL,Pres_Med_VITAL] = evaluateSequenceAUC(resPath,'VITAL');
[~,~,IOU_AUC_ECO,Pres_Med_ECO] = evaluateSequenceAUC(resPath,'ECO');
[~,~,IOU_AUC_DSLT,Pres_Med_DSLT] = evaluateSequenceAUC(resPath,'DSLT');




%Pres_Med_Mtrx_SiamRPNpp = reshape(Pres_Med_SiamRPNpp - Pres_Med_JROTM,10,10);



% IOU_AUC_Mtrx_SiamRPNpp  = reshape(IOU_AUC_SiamRPNpp  - IOU_AUC_JROTM,10,10);
% IOU_AUC_Mtrx_VITAL  = reshape(IOU_AUC_VITAL  - IOU_AUC_JROTM,10,10);
% IOU_AUC_Mtrx_ECO  = reshape(IOU_AUC_ECO  - IOU_AUC_JROTM,10,10);
% IOU_AUC_Mtrx_DSTL  = reshape(IOU_AUC_DSLT  - IOU_AUC_JROTM,10,10);
IOU_AUC_Mtrx_SiamRPNpp  = IOU_AUC_SiamRPNpp  - IOU_AUC_JROTM;
IOU_AUC_Mtrx_VITAL  = IOU_AUC_VITAL  - IOU_AUC_JROTM;
IOU_AUC_Mtrx_ECO  = IOU_AUC_ECO  - IOU_AUC_JROTM;
IOU_AUC_Mtrx_DSTL  = IOU_AUC_DSLT  - IOU_AUC_JROTM;








show = IOU_AUC_Mtrx_SiamRPNpp;
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

% figure;
% h = heatmap(IOU_AUC_Mtrx_SiamRPNpp);   %title('asdfadsf');
% set(h,'ColorLimits',[-fkCmlim fkCmlim]);
% set(h,'Colormap',colormap);
% title('SiamRPN++');
% figure;





show = IOU_AUC_Mtrx_VITAL; 
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
% h = heatmap(IOU_AUC_Mtrx_VITAL);   %title('asdfadsf');
% set(h,'ColorLimits',[-fkCmlim fkCmlim]);
% set(h,'Colormap',colormap);
% title('VITAL');






show = IOU_AUC_Mtrx_ECO;
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
% figure;
% h = heatmap(IOU_AUC_Mtrx_ECO);   %title('asdfadsf');
% set(h,'ColorLimits',[-fkCmlim fkCmlim]);
% set(h,'Colormap',colormap);
% title('ECO');




show = IOU_AUC_Mtrx_DSTL;
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
% figure;
% h = heatmap(IOU_AUC_Mtrx_DSTL);   %title('asdfadsf');
% set(h,'ColorLimits',[-fkCmlim fkCmlim]);
% set(h,'Colormap',colormap);
% title('DSLT');



seqs=ConfigSeqs100;


f1 = IOU_AUC_Mtrx_DSTL < 0; 
f2 = IOU_AUC_Mtrx_ECO< 0; 
f3 = IOU_AUC_Mtrx_VITAL < 0; 
f4 = IOU_AUC_Mtrx_SiamRPNpp < 0; 

res = f1.*f2.*f3.*f4;


goodSet = seqs(find(res));



z = 1;
return 
















































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































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



