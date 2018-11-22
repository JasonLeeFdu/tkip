function trackers=ConfigStateofArtMatTrackers
trackersmat={
    struct('name','MCPF','namePaper','MCPF','workPath','/home/winston/workSpace/PycharmProjects/tracking/pjs/MCPF/'),...
    struct('name','CREST','namePaper','CREST','workPath','/home/winston/workSpace/PycharmProjects/tracking/pjs/CREST/'),...
    struct('name','ECO','namePaper','ECO','workPath','/home/winston/workSpace/PycharmProjects/tracking/pjs/ECO/'),...
    struct('name','VITAL','namePaper','VITAL','workPath','/home/winston/workSpace/PycharmProjects/tracking/pjs/Vital/')...   
    struct('name','MDNet','namePaper','MDNet','workPath','/home/winston/workSpace/PycharmProjects/tracking/pjs/MDNet/')...   
    struct('name','VITAL_Adv','namePaper','VITAL_Adv','workPath','/home/winston/workSpace/PycharmProjects/tracking/TrackingGuidedInterpolation/BaselineAdv/Vital'),...%yellow
    struct('name','VITAL_Ori','namePaper','VITAL_Ori','workPath','/home/winston/workSpace/PycharmProjects/tracking/pjs/Vital')
    };



trackers = [trackersmat];

% 
% 