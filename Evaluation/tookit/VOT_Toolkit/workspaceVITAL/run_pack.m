% This script can be used to pack the results and submit them to a challenge.

addpath('/home/winston/workSpace/PycharmProjects/tracking/TrackingGuidedInterpolation/Evaluation/tookit/VOT_Toolkit'); toolkit_path; % Make sure that VOT toolkit is in the path

[sequences, experiments] = workspace_load();

tracker = tracker_load('VITAL_ADV3_6_1__wrapper');

workspace_submit(tracker, sequences, experiments);

