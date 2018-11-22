clear all;
clc;
test_seq='Bolt';
conf = genConfig('otb',test_seq);
net=fullfile('../models/otbModel.mat');
zz = conf.imgList;
zz = zz(1:30);
[result,fps] = run_VITAL(zz, conf.gt(1,:));