function res = optF(imgSet,To,type)
% The expected interpolation algorithms that is used 
% to interpolate the frames 

% This simulate version is just the utilize the change of the exact file
% name
%% load, instead of calculation

% test:
%% OTB100-frm

%% ONLY for vot converters
if To < 0
    %resolve To
    p1 = strfind(path,'/');
    p2 = strfind(path,'.');
    To = str2double(path(p1(end)+1:p2(end)-1));
    token = imgSet;
else
    token = imgSet{To};
end


resIdx = To -1;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                     CONFIGURATION
OTB100_FRM_OPT_PATH = '/home/winston/workSpace/PycharmProjects/tracking/TrackingGuidedInterpolation/Datasets/Original/OTB100_optFlow/';
OTB100_ITP_OPT_PATH = '/home/winston/workSpace/PycharmProjects/tracking/TrackingGuidedInterpolation/Datasets/OriginalInterp2/OTB100_optflow_itpNori/';
VOT2016_FRM_OPT_PATH = '/home/winston/workSpace/PycharmProjects/tracking/TrackingGuidedInterpolation/Datasets/Original/vot2016_optFlow/';
VOT2016_ITP_OPT_PATH = '/home/winston/Datasets/Tracking/OriginalInterp2/VOT2016_optflow_itpNori/';
TempleColor128_FRM_OPT_PATH = '/home/winston/workSpace/PycharmProjects/tracking/TrackingGuidedInterpolation/Datasets/Original/TempleColor128_optFlow/';
TempleColor128_ITP_OPT_PATH = '/home/winston/Datasets/Tracking/OriginalInterp2/TempleColor128_optflow_itpNori/';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ext  = 'mat';


if strcmp(type,'frm')
    if length(strfind(token,'OTB')) > 0 %%%
        n = 4;
        format = ['%0' num2str(n) 'd'  ];
        targetFile = sprintf([format '_5.' ext],resIdx);
        targetPath  = OTB100_FRM_OPT_PATH;
        tmp = token;
        poses = strfind(tmp,'/');
        videoName = tmp(poses(end-2)+1:poses(end-1)-1);
    elseif length(strfind(token,'olor128')) > 0 %%%
        n = 4;
        format = ['%0' num2str(n) 'd'  ];
        targetFile = sprintf([format '_5.' ext],resIdx);
        targetPath  = TempleColor128_FRM_OPT_PATH;
        tmp = token;
        poses = strfind(tmp,'/');
        videoName = tmp(poses(end-2)+1:poses(end-1)-1);
    elseif length(strfind(lower(token),'vot')) > 0 %%%
        n = 8;
        format = ['%0' num2str(n) 'd'  ];
        targetFile = sprintf([format '_5.' ext],resIdx);
        targetPath  = VOT2016_FRM_OPT_PATH;
        tmp = token;
        poses = strfind(tmp,'/');
        videoName = tmp(poses(end-1)+1:poses(end)-1);
        
    end
elseif strcmp(type,'itp') 
    resIdx = To;
    if length(strfind(token,'OTB')) > 0 %%%
        n = 4;
        format = ['%0' num2str(n) 'd'  ];
        targetFile = sprintf([format '__5.' ext],resIdx);
        targetPath  = OTB100_ITP_OPT_PATH;
        tmp = token;
        poses = strfind(tmp,'/');
        videoName = tmp(poses(end-2)+1:poses(end-1)-1);
    elseif length(strfind(token,'olor128')) > 0
        n = 4;
        format = ['%0' num2str(n) 'd'  ];
        targetFile = sprintf([format '__5.' ext],resIdx);
        targetPath  = TempleColor128_ITP_OPT_PATH;
        tmp = token;
        poses = strfind(tmp,'/');
        videoName = tmp(poses(end-2)+1:poses(end-1)-1);
    elseif length(strfind(lower(token),'vot')) > 0
        n = 8;
        format = ['%0' num2str(n) 'd'  ];
        targetFile = sprintf([format '__5.' ext],resIdx);
        targetPath  = VOT2016_ITP_OPT_PATH;
        tmp = token;
        poses = strfind(tmp,'/');
        videoName = tmp(poses(end-1)+1:poses(end)-1);
    end
end


load(fullfile(targetPath,videoName,targetFile));
res = optFlow;
end

