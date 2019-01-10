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
OTB100_FRM_OPT_PATH = '';
OTB100_ITP_OPT_PATH = '';
VOT2016_FRM_OPT_PATH = '';
VOT2016_FRM_OPT_PATH = '';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


Res = imgSet(To);
token = imgSet{1};
tail = strfind(token,'/');
tail = tail(end);
path = token(1:tail-1);
file = token(tail+1:end);
dot  = strfind(file,'.');
fn   = file(1:dot-1);
ext  = 'mat';
n    = length(fn);

flowToken = '%s_optFlow'; %'OTB100_optFlow';

if strcmp(type,'frm')
    if length(strfind(imgSet{To},'OTB')) > 0
        format = ['%0' num2str(n) 'd'  ];
        targetFile = sprintf([format '_5.' ext],resIdx);
        targetPath  = [path(1:41) 'OTB100_optFlow' path(48:end-3)];
    elseif length(strfind(imgSet{To},'128')) > 0
        format = ['%0' num2str(n) 'd'  ];
        targetFile = sprintf([format '_5.' ext],resIdx);
        targetPath  = [path(1:55) '_optFlow' path(56:end-3)];
        
    elseif length(strfind(lower(imgSet{To}),'vot')) > 0
        
    end
elseif strcmp(type,'itp') 
    if length(strfind(imgSet{To},'OTB')) > 0
        format = ['%0' num2str(n) 'd'  ];
        targetFile = sprintf([format '_5.' ext],resIdx);
        targetPath  = [path(1:41) 'OTB100_optFlow' path(48:end-3)];
    elseif length(strfind(imgSet{To},'128')) > 0
        format = ['%0' num2str(n) 'd'  ];
        targetFile = sprintf([format '_5.' ext],resIdx);
    aq    targetPath  = [path(1:55) '_optFlow' path(56:end-3)];
    
    elseif length(strfind(lower(imgSet{To}),'vot')) > 0
        z= 1;
    end
    
end


%% debug
str = fullfile(targetPath,targetFile);
fprintf('Debug: %s \n',str);


% load(fullfile(targetPath,targetFile));
% res = optFlow;
end

