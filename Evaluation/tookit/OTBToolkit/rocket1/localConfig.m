function [config] = localConfig()
%LOCALCONFIG Summary of this function goes here
%   Detailed explanation goes here
config = [];
config.idxVideoSet = [13,15,31,39,40,45,65,91,98,100]; 
config.thArr1 = 0:0.1:1;
config.thArr2 = 0:0.02:0.2;
config.thArr3 = [0.00285 0.00415 0.0052 0.0062 0.0073 0.00855 0.011];
config.THRESHOLDSETOVERLAP = 0:0.01:0.2;
end


