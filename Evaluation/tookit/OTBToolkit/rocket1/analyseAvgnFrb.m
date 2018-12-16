FLOW_BASE = '/home/winston/Datasets/Tracking/Original/OTB100_optFlow';
vnDir = dir(FLOW_BASE);
vnames = {};
bin = 0.0005:0.001:0.9995;
resBar = zeros(1,length(bin));
sum = 0;
for i = 3:length(vnDir)
    vnames{end+1} = vnDir(i).name ;    
end

for i = 1:length(vnames)    %every clip
    fprintf('========================================开始处理视频：%s(========================================\n',vnames{i});
    frDir = dir(fullfile(FLOW_BASE,vnames{i}));
    frNames = {};
    sum = sum + length(frDir)-2
end
avg = sum /100


 