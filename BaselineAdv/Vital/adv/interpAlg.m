function [Res] = interpAlg(imgSet,To)
% The expected interpolation algorithms that is used 
% to interpolate the frames 

% This simulate version is just the utilize the change of the exact file
% name

dsRate = 2;
resIdx = To -1;
if dsRate == 2
   resIdx = 2*To - 2;
   
end

Res = imgSet(To);
token = imgSet{1};
tail = strfind(token,'/');
tail = tail(end);
path = token(1:tail-1);
file = token(tail+1:end);
dot  = strfind(file,'.');
fn   = file(1:dot-1);
ext  = file(dot+1:end);
n    = length(fn);
format = ['%0' num2str(n) 'd'  ];
targetFile = sprintf([format '.' ext],resIdx);
targetPath  = [path(1:32) 'OriginalInterp2' path(41:end)];

Res = imread(fullfile(targetPath,targetFile));



end

