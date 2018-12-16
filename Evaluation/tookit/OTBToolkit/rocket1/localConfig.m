function [config] = localConfig()
%LOCALCONFIG Summary of this function goes here
%   Detailed explanation goes here
config = [];
config.idxVideoSet = [13,15,31,39,40,45,65,91,98,100]; 
config.thArr1 = 0:0.1:1;
config.thArr2 = 0:0.02:0.2;
config.thArr3 = 0:0.003:0.06;

config.THRESHOLDSETOVERLAP = 0:0.05:1;


end


