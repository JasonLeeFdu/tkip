function res = optF(imgSet,To)
% The expected interpolation algorithms that is used 
% to interpolate the frames 

% This simulate version is just the utilize the change of the exact file
% name

dsRate = 2;
resIdx = To -1;


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
format = ['%0' num2str(n) 'd'  ];
targetFile = sprintf([format '_5.' ext],resIdx);
targetPath  = [path(1:41) 'OTB100_optFlow' path(48:end-3)];

load(fullfile(targetPath,targetFile));
res = optFlow;
end

