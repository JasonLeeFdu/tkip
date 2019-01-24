function [Res] = interpAlg(imgSet,To)
% The expected interpolation algorithms that is used 
% to interpolate the frames 

% This simulate version is just the utilize the change of the exact file
% name


if To < 0
    %resolve To
    p1 = strfind(path,'/');
    p2 = strfind(path,'.');
    To = str2double(path(p1(end)+1:p2(end)-1));
    token = imgSet;
else
    token = imgSet{To};
end




dsRate = 2;
resIdx = To -1;
if dsRate == 2
   resIdx = 2*To - 2;
end




ext  = file(dot+1:end);

OTB100_FRM_OPT_PATH = '/home/winston/workSpace/PycharmProjects/tracking/TrackingGuidedInterpolation/Datasets/OriginalInterp2/OTB100/';
TempleColor128_FRM_OPT_PATH = '/home/winston/workSpace/PycharmProjects/tracking/TrackingGuidedInterpolation/Datasets/OriginalInterp2/TempleColor128/';
VOT2016_FRM_OPT_PATH = '/home/winston/workSpace/PycharmProjects/tracking/TrackingGuidedInterpolation/Datasets/OriginalInterp2/VOT2016';



if length(strfind(token,'OTB')) > 0 %%%
    n = 4;
    format = ['%0' num2str(n) 'd'  ];
    targetFile = sprintf([format '.' ext],resIdx);
    targetPath  = OTB100_FRM_OPT_PATH;
    tmp = token;
    poses = strfind(tmp,'/');
    videoName = tmp(poses(end-2)+1:poses(end-1)-1);
    videoName = fullfile(videoName,'img');
elseif length(strfind(token,'olor128')) > 0 %%%
    n = 4;
    format = ['%0' num2str(n) 'd'  ];
    targetFile = sprintf([format '.' ext],resIdx);
    targetPath  = TempleColor128_FRM_OPT_PATH;
    tmp = token;
    poses = strfind(tmp,'/');
    videoName = tmp(poses(end-2)+1:poses(end-1)-1);
elseif length(strfind(lower(token),'vot')) > 0 %%%
    n = 8;
    format = ['%0' num2str(n) 'd'  ];
    targetFile = sprintf([format '.' ext],resIdx);
    targetPath  = VOT2016_FRM_OPT_PATH;
    tmp = token;
    poses = strfind(tmp,'/');
    videoName = tmp(poses(end-1)+1:poses(end)-1);

end

Res = imread(fullfile(targetPath,videoName,targetFile));

end

