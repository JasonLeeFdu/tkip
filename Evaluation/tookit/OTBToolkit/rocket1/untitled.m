path = '/home/winston/workSpace/PycharmProjects/tracking/TrackingGuidedInterpolation/Evaluation/results/MotionDiff_Opt1/';
fnSet = dir(path);
IOU_AUCs = 0;
Precs_Thress = 0;
counter = 0;
for i = 3:length(fnSet)
    counter = counter + 1;
    fn = fullfile(path,fnSet(i).name);
    [IOU_AUC,Precs_Thres] = calculateIOU_N_Precision(fn);
    IOU_AUCs = IOU_AUCs + IOU_AUC;
    Precs_Thress = Precs_Thres + Precs_Thress;
end

IOU_AUCs = IOU_AUCs / counter
Precs_Thress = Precs_Thress / counter
