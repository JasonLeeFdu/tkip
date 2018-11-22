clear all;
clc;
test_seq='Bolt';
conf = genConfig('otb',test_seq);
net=fullfile('../models/otbModel.mat');

vm = VITAL_MODULE(conf.imgList, conf.gt(1,:));


resBox = conf.gt(1,:);

results = zeros(30,4);

for i = 2:30
    
    resBox = vm.trackNext(conf.imgList{i},resBox);
    results(i,:) = resBox;
    
end