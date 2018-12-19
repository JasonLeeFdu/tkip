FLOW_BASE = '/home/winston/Datasets/Tracking/Original/OTB100_optFlow';
GT_BASE = '/home/winston/workSpace/PycharmProjects/tracking/TrackingGuidedInterpolation/Datasets/Original/OTB100/';
constFn = 'groundtruth_rect.txt';
vnDir = dir(FLOW_BASE);
vnames = {};
bin = 0.0005:0.001:0.9995;
resBar = zeros(1,length(bin));

conf = config();


for i = 3:length(vnDir)
    vnames{end+1} = vnDir(i).name ;    
end

for i = 1:length(vnames)    %every clip
    fprintf('========================================开始处理视频：%s(========================================\n',vnames{i});
    frDir = dir(fullfile(FLOW_BASE,vnames{i}));
    frNames = {};
    gtFn = fullfile(GT_BASE,vnames{i},constFn);
    gtBoxes = load(gtFn);    
    for jj = 3:length(frDir)
        frNames{end+1} = frDir(jj).name;
    end
    
    
    %% 需要判断是否是奇怪的视频，并且要确定结束开始帧
    % 初始化
    
    if ismember(vnames{i},conf.weirdVideoList)
       disp('YYYYEEEEESSSSS');
       tmp = conf.OriginalStartEndF(vnames{i});
       startFr = tmp(1);
       endFr = tmp(2);
  
    else
       startFr = 1;
       endFr   = length(frNames);        
    end
    
    %% %%%%
    for j = startFr:endFr-1
       if mod(j,20) == 0
           fprintf('.');
       end
       if mod(j,200) == 0
           fprintf('.');
       end
       %%%%%% REAL POS-- get the optFlow in time j
       fn = fullfile(FLOW_BASE,vnames{i},frNames{j});
       load(fn);
       % optFlow
       OptFlowAmplitude = sqrt(optFlow(:,:,1).^2 + optFlow(:,:,2).^2);
       resBar = resBar + hist(OptFlowAmplitude(:),bin);
    end
    fprintf('\n');
end

bar(bin,resBar);%  bin1 - 0.3 = 0.001;bin3 -0.5=0.003;bin6 - 0.7=0.006

% bin3 - 0.3 == 0.003;bin
