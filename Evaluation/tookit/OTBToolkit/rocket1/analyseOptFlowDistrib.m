FLOW_BASE = '/home/winston/Datasets/Tracking/Original/OTB100_optFlow';
vnDir = dir(FLOW_BASE);
vnames = {};
bin = 0.0005:0.001:0.9995;
resBar = zeros(1,length(bin));

for i = 3:length(vnDir)
    vnames{end+1} = vnDir(i).name ;    
end

for i = 1:length(vnames)    %every clip
    fprintf('========================================开始处理视频：%s(========================================\n',vnames{i});
    frDir = dir(fullfile(FLOW_BASE,vnames{i}));
    frNames = {};
    for jj = 3:length(frDir)
        frNames{end+1} = frDir(jj).name;
    end
    
    for j = 1:length(frNames)
       if mod(j,20) == 0
           fprintf('.');
       end
       if mod(j,200) == 0
           fprintf('.');
       end
       fn = fullfile(FLOW_BASE,vnames{i},frNames{j});
       load(fn);
       % optFlow
       OptFlowAmplitude = sqrt(optFlow(:,:,1).^2 + optFlow(:,:,2).^2);
       resBar = resBar + hist(OptFlowAmplitude(:),bin);
    end
    fprintf('\n');
end
bar(bin,resBar);


