function res = optF(imgSet,To,type)
% The expected interpolation algorithms that is used 
% to interpolate the frames 

% This simulate version is just the utilize the change of the exact file
% name
%% load, instead of calculation
dsRate = 2;
resIdx = To -1;

% test:
%% OTB100-frm



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                     CONFIGURATION
OTB100_FRM_OPT_PATH = '/home/winston/workSpace/PycharmProjects/tracking/TrackingGuidedInterpolation/Datasets/Original/OTB100_optFlow/';
OTB100_ITP_OPT_PATH = '/home/winston/workSpace/PycharmProjects/tracking/TrackingGuidedInterpolation/Datasets/OriginalInterp2/OTB100_optflow_itpNori/';
VOT2016_FRM_OPT_PATH = '/home/winston/workSpace/PycharmProjects/tracking/TrackingGuidedInterpolation/Datasets/Original/vot2016_optFlow/';
VOT2016_ITP_OPT_PATH = '';
TempleColor128_FRM_OPT_PATH = '/home/winston/workSpace/PycharmProjects/tracking/TrackingGuidedInterpolation/Datasets/Original/TempleColor128_optFlow/';
TempleColor128_ITP_OPT_PATH = '';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


Res = imgSet(To);
token = imgSet{1};
tail = strfind(token, '/');
tail = tail(end);
path = token(1:tail-1);
file = token(tail+1:end);
dot  = strfind(file,'.');
fn   = file(1:dot-1);
ext  = 'mat';

if strcmp(type,'frm')
    if length(strfind(imgSet{To},'OTB')) > 0
        n = 4;
        format = ['%0' num2str(n) 'd'  ];
        targetFile = sprintf([format '_5.' ext],resIdx);
        targetPath  = OTB100_FRM_OPT_PATH;
        tmp = imgSet{To};
        poses = strfind(tmp,'/');
        videoName = tmp(poses(end-2)+1:poses(end-1)-1);
    elseif length(strfind(imgSet{To},'olor128')) > 0
        n = 4;
        format = ['%0' num2str(n) 'd'  ];
        targetFile = sprintf([format '_5.' ext],resIdx);
        targetPath  = TempleColor128_FRM_OPT_PATH;
        tmp = imgSet{To};
        poses = strfind(tmp,'/');
        videoName = tmp(poses(end-2)+1:poses(end-1)-1);
    elseif length(strfind(lower(imgSet{To}),'vot')) > 0
        n = 8;
        format = ['%0' num2str(n) 'd'  ];
        targetFile = sprintf([format '_5.' ext],resIdx);
        targetPath  = VOT2016_FRM_OPT_PATH;
        tmp = imgSet{To};
        poses = strfind(tmp,'/');
        videoName = tmp(poses(end-2)+1:poses(end-1)-1);
        
    end
elseif strcmp(type,'itp') 
    if length(strfind(imgSet{To},'OTB')) > 0
        n = 4;
        format = ['%0' num2str(n) 'd'  ];
        targetFile = sprintf([format '__5.' ext],resIdx);
        targetPath  = OTB100_ITP_OPT_PATH;
        tmp = imgSet{To};
        poses = strfind(tmp,'/');
        videoName = tmp(poses(end-2)+1:poses(end-1)-1);
    elseif length(strfind(imgSet{To},'olor128')) > 0
        n = 4;
        format = ['%0' num2str(n) 'd'  ];
        targetFile = sprintf([format '__5.' ext],resIdx);
        targetPath  = TempleColor128_ITP_OPT_PATH;
        tmp = imgSet{To};
        poses = strfind(tmp,'/');
        videoName = tmp(poses(end-2)+1:poses(end-1)-1);
    elseif length(strfind(lower(imgSet{To}),'vot')) > 0
        n = 8;
        format = ['%0' num2str(n) 'd'  ];
        targetFile = sprintf([format '__5.' ext],resIdx);
        targetPath  = VOT2016_ITP_OPT_PATH;
        tmp = imgSet{To};
        poses = strfind(tmp,'/');
        videoName = tmp(poses(end-2)+1:poses(end-1)-1);
    end
end


load(fullfile(targetPath,videoName,targetFile));
res = optFlow;
end

