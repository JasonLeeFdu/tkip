imgPath = '/home/winston/workSpace/PycharmProjects/tracking/TrackingGuidedInterpolation/Evaluation/tookit/VOT_Toolkit/workspace/sequences/fish2/color/00000012.jpg';


OPT_BASE = '/home/winston/workSpace/PycharmProjects/tracking/TrackingGuidedInterpolation/Datasets/Original/vot2016_optFlow/';
img = imread(imgPath);
poses = strfind(imgPath,'/');
fnMod = '%08d_5.mat';
% clue1: the frame number and opt fn
startt = poses(end)+1;
endd   = length(imgPath)-4;
To = str2num(imgPath(startt:endd));
To = To - 1;
fn = sprintf(fnMod,To);
% clue2: the clip name
startt = poses(end-2)+1;
endd   = poses(end-1)-1;
clipName = imgPath(startt:endd);
% get the respective optimal flow
% get the opt-path
optFn = fullfile(OPT_BASE ,clipName,fn)
load(optFn);
res = optFlow;



