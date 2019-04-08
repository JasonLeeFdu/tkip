function trackers=ablationTrkers
trackersmat={
  	struct('name','Baseline_TCR_MG_Smpl','namePaper','Baseline_TCR_MG_Smpl','workPath','/home/winston/workSpace/PycharmProjects/tracking/TrackingGuidedInterpolation/BaselineAdv/Vital'),...%yellow
    struct('name','Baseline_TCR_MG','namePaper','Baseline_TCR_MG','workPath','/home/winston/workSpace/PycharmProjects/tracking/pjs/MCPF/'),...
    struct('name','Baseline_TCR','namePaper','Baseline_TCR','workPath','/home/winston/workSpace/PycharmProjects/tracking/pjs/CREST/'),...
    struct('name','Baseline_MG','namePaper','Baseline_MG','workPath','/home/winston/workSpace/PycharmProjects/tracking/pjs/DRTAL/'),...
    struct('name','BaselineVITAL','namePaper','BaselineVITAL','workPath','/home/winston/workSpace/PycharmProjects/tracking/pjs/ECO/')
    };
trackers = [trackersmat];

% 
% 