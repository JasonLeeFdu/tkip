function trackers=ConfigStateofArtMatTrackers
trackersmat={
  	struct('name','VITAL_Adv','namePaper','VITAL_Adv','workPath','/home/winston/workSpace/PycharmProjects/tracking/TrackingGuidedInterpolation/BaselineAdv/Vital'),...%yellow
    struct('name','MCPF','namePaper','MCPF','workPath','/home/winston/workSpace/PycharmProjects/tracking/pjs/MCPF/'),...
    struct('name','CREST','namePaper','CREST','workPath','/home/winston/workSpace/PycharmProjects/tracking/pjs/CREST/'),...
    struct('name','DATRL','namePaper','DAT','workPath','/home/winston/workSpace/PycharmProjects/tracking/pjs/DRTAL/'),...
    struct('name','ECO','namePaper','ECO','workPath','/home/winston/workSpace/PycharmProjects/tracking/pjs/ECO/'),...
    struct('name','MCCT','namePaper','MCCT','workPath','/home/winston/workSpace/PycharmProjects/tracking/pjs/MCCT/'),...
    struct('name','DaSiamRPN','namePaper','DaSiamRPN','workPath','/home/winston/workSpace/PycharmProjects/tracking/pjs/DaSiamRPN/'),...
    struct('name','VITAL','namePaper','VITAL','workPath','/home/winston/workSpace/PycharmProjects/tracking/pjs/Vital/')...   
    struct('name','MDNet','namePaper','MDNet','workPath','/home/winston/workSpace/PycharmProjects/tracking/pjs/MDNet/')...   
    struct('name','DSLT','namePaper','DSLT','workPath','/home/winston/workSpace/PycharmProjects/tracking/TrackingGuidedInterpolation/DSLT'),...yellow
    struct('name','DWSiam','namePaper','DWSiam','workPath','/home/winston/workSpace/PycharmProjects/tracking/TrackingGuidedInterpolation/DSLT'),...yellow
    struct('name','SiamRPN++','namePaper','SiamRPN++','workPath','/home/winston/workSpace/PycharmProjects/tracking/TrackingGuidedInterpolation/DSLT')%,...yellow
    %struct('name','VITAL_Ori','namePaper','VITAL_Ori','workPath','/home/winston/workSpace/PycharmProjects/tracking/pjs/Vital')
    
    };


trackers = [trackersmat];

% 
% 