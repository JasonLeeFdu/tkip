function [ result ,Interp_bbox,Choice,th,fps] = run_VITAL_ADV3_7_1(imgSet, init_rect,localTh)

%%% 四中心算法，上一帧框、上一帧光流框(_1)、插帧框、插帧光流框(_5)
%%% 本算法目前需要插帧模型的辅助，目前仅仅在OTB集合上进行模拟

run ./matconvnet/matlab/vl_setupnn ;
addpath('./utils');
addpath('./models');
addpath('./vital');
addpath('./tracking');
addpath('./adv');           					%%  插帧算法、求光流算法



display = false;
global gpu;
gpu=true;

%conf = winconfig;
conf = config;
net=fullfile('./models/otbModel.mat');

%% Initialization
% fprintf('Initialization...\n');   

nFrames = length(imgSet);

img = imread(imgSet{1});
if(size(img,3)==1), img = cat(3,img,img,img); end
targetLoc = init_rect;
result = zeros(nFrames, 4); result(1,:) = targetLoc;
Interp_bbox = zeros(2*nFrames-1,4);Interp_bbox(1,:) = targetLoc;
interpCounter = 2; %always appears at the present position
targetScores = zeros(nFrames,1);
targetScores(1) = 2.0;
[net_conv, net_fc, opts] = mdnet_init(img, net);
[net_G, opts_net] = G_init();


CENTER_DELTA = opts.nSamples;



%% Train a bbox regressor
if(opts.bbreg)
    pos_examples = gen_samples('uniform_aspect', targetLoc, opts.bbreg_nSamples*10, opts, 0.3, 10);
    r = overlap_ratio(pos_examples,targetLoc);
    pos_examples = pos_examples(r>0.6,:);
    pos_examples = pos_examples(randsample(end,min(opts.bbreg_nSamples,end)),:); % an example of the  
    feat_conv = mdnet_features_convX(net_conv, img, pos_examples, opts); % multi-threaded
    X = permute(gather(feat_conv),[4,3,1,2]);
    X = X(:,:);
    bbox = pos_examples;
    bbox_gt = repmat(targetLoc,size(pos_examples,1),1);
    bbox_reg = train_bbox_regressor(X, bbox, bbox_gt);
end

%% Extract training examples
% fprintf('  extract features...\n');

% draw positive/negative samples
pos_examples = gen_samples('gaussian', targetLoc, opts.nPos_init*2, opts, 0.1, 5);
r = overlap_ratio(pos_examples,targetLoc);
pos_examples = pos_examples(r>opts.posThr_init,:);
pos_examples = pos_examples(randsample(end,min(opts.nPos_init,end)),:);

neg_examples = [gen_samples('uniform', targetLoc, opts.nNeg_init, opts, 1, 10);...
    gen_samples('whole', targetLoc, opts.nNeg_init, opts)];
r = overlap_ratio(neg_examples,targetLoc);
neg_examples = neg_examples(r<opts.negThr_init,:);
neg_examples = neg_examples(randsample(end,min(opts.nNeg_init,end)),:);

examples = [pos_examples; neg_examples];
pos_idx = 1:size(pos_examples,1);
neg_idx = (1:size(neg_examples,1)) + size(pos_examples,1);

% extract conv3 features
feat_conv = mdnet_features_convX(net_conv, img, examples, opts);
pos_data = feat_conv(:,:,:,pos_idx);
neg_data = feat_conv(:,:,:,neg_idx);


%% Learning CNN
% fprintf('  training cnn...\n');
%%%$$$ finetune with hard-minging ,训练与微调第�?�?,使得NET_FC获得来自第一帧的调节
net_fc = mdnet_finetune_hnm(net_fc,pos_data,neg_data,opts,...
    'maxiter',opts.maxiter_init,'learningRate',opts.learningRate_init);

net_G = G_pretrain(net_fc, net_G, pos_data, opts_net);


%% Prepare training data for online update
total_pos_data = cell(1,1,1,nFrames);
total_neg_data = cell(1,1,1,nFrames);

neg_examples = gen_samples('uniform', targetLoc, opts.nNeg_update*2, opts, 2, 5);
r = overlap_ratio(neg_examples,targetLoc);
neg_examples = neg_examples(r<opts.negThr_init,:);
neg_examples = neg_examples(randsample(end,min(opts.nNeg_update,end)),:);

examples = [pos_examples; neg_examples];
pos_idx = 1:size(pos_examples,1);
neg_idx = (1:size(neg_examples,1)) + size(pos_examples,1);
% 从第�?帧提取特�?
feat_conv = mdnet_features_convX(net_conv, img, examples, opts);
total_pos_data{1} = feat_conv(:,:,:,pos_idx);
total_neg_data{1} = feat_conv(:,:,:,neg_idx);

success_frames = 1;
trans_f = opts.trans_f;
scale_f = opts.scale_f;


tic;
startt = toc;

target_score = 2.8888888;
Choice(1)= 0.0;
th = -1;

%% Main loop
for To = 2:nFrames
    %% Whether need enhancement, judged by 'Local  Difference' M12011155
    optFlow = optF(imgSet,To,'frm');     %此处去计算TimeO-1的光�?
    %% $$$$$ 其实如何把光流到新的框做�?个小网络应该也能有不错的效果
    InterpSWITCH = false; % this variable is responsible for interpolation reinforcement
    OptRectSWITCH = true; % this variable is responsible for optical flow rect sample point enhancement
    
    
    %% %$$$ CENTER 1  targetLoc  
    
    %% %$$$ CENTER 2  newRect
    newRect = optShiftRect(targetLoc,optFlow);    
    
    %% %$$$ CENTER 3  targetLoc_Itp
    imgInterpLast = interpAlg(imgSet,To);%$
    if(size(imgInterpLast,3)==1), imgInterpLast = cat(3,imgInterpLast,imgInterpLast,imgInterpLast); end
    samples_Itp = gen_samples('gaussian', targetLoc, opts.nSamples, opts, trans_f, scale_f);%$
    %%% net_conv is the target network I have to worry about.
    feat_conv_Itp = mdnet_features_convX(net_conv, imgInterpLast, samples_Itp, opts);%%
    feat_fc_Itp = mdnet_features_fcX(net_fc, feat_conv_Itp, opts);%% 
    feat_fc_Itp = squeeze(feat_fc_Itp)';%%
    [scores_Itp,idx_Itp] = sort(feat_fc_Itp(:,2),'descend');  %%
    target_score_Itp = mean(scores_Itp(1:5));%%
    targetLoc_Itp = round(mean(samples_Itp(idx_Itp(1:5),:))); %%
   
    
    %% %$$$ CENTER 4  targetLoc_Itp_Opt
    optItpFlow = optF(imgSet,To,'itp');
    targetLoc_Itp_Opt = optShiftRect(targetLoc_Itp,optItpFlow);
    

    
    
    
    %% Estimation 下面�  ?始好好的跑检测的步骤
  
	samples1 = gen_samples('gaussian', targetLoc, opts.nSamples, opts, trans_f, scale_f);
    samples2 = gen_samples('gaussian', newRect, opts.nSamples, opts, trans_f, scale_f);
    samples3 = gen_samples('gaussian', targetLoc_Itp, opts.nSamples, opts, trans_f, scale_f);
    samples4 = gen_samples('gaussian', targetLoc_Itp_Opt, opts.nSamples, opts, trans_f, scale_f);
    samples = [samples1;samples2;samples3;samples4];
    
    img = imread(imgSet{To});
    if(size(img,3)==1), img = cat(3,img,img,img); end 
    
    
    
    % draw target candidates,按照高斯的方�?,在上�?帧附近采�?,并且利用函数mdnet_features_convX抽取他们的特�?
    feat_conv = mdnet_features_convX(net_conv, img, samples, opts);
    
    % evaluate the candidates ===> 结果计算的位�?
    feat_fc = mdnet_features_fcX(net_fc, feat_conv, opts);
    feat_fc = squeeze(feat_fc)';
    

    nCenter      = size(feat_fc,1)/CENTER_DELTA;
    idxMtrx      = zeros(nCenter,CENTER_DELTA);
    tarlocMtrx   = zeros(nCenter,4);
    tarScores    = zeros(nCenter,1);
    
    for k = 1:nCenter
       offset = CENTER_DELTA * (k-1);
       feat_fc_slice = feat_fc(offset+1:offset+CENTER_DELTA,:);
       samples_slice = samples(offset+1:offset+CENTER_DELTA,:);
       [scores,idx] = sort(feat_fc_slice(:,2),'descend');
       ts = mean(scores(1:5));
       tl = round(mean(samples_slice(idx(1:5),:)));
       idxMtrx(k,:) = idx + offset;
       tarlocMtrx(k,:) = tl; 
       tarScores(k,:) = ts;
    end
    [~,idxChannelChoice] = max(tarScores);
    targetLoc = tarlocMtrx(idxChannelChoice,:);
    target_score = tarScores(idxChannelChoice);
    
    % final target without regression
    result(To,:) = targetLoc;
    Interp_bbox(interpCounter,:) = targetLoc;
    targetScores(To) = target_score;
    % extend search space in case of failure 作用于前面采样步�?
    if(target_score<0)
        trans_f = min(1.5, 1.1*trans_f);
    else
        trans_f = opts.trans_f;
    end
    % if InterpSWITCH
    % bbox regression ###$$$ 这个可能是下面工作将要解决的问题
    if(opts.bbreg && target_score>0)
        X_ = permute(gather(feat_conv(:,:,:,idxMtrx(idxChannelChoice,1:5))),[4,3,1,2]);
        X_ = X_(:,:);
        bbox_ = samples(idxMtrx(idxChannelChoice,1:5),:);
        pred_boxes = predict_bbox_regressor(bbox_reg.model, X_, bbox_);%feature and old box to gett new one. RCNN
        result(To,:) = round(mean(pred_boxes,1));
        Interp_bbox(interpCounter,:) = round(mean(pred_boxes,1));
    end
    interpCounter = interpCounter + 1;
    %end
    %% Prepare training data  本图的追踪结果基�?上记�?
    if(target_score>0)
        pos_examples = gen_samples('gaussian', targetLoc, opts.nPos_update*2, opts, 0.1, 5);
        r = overlap_ratio(pos_examples,targetLoc);
        pos_examples = pos_examples(r>opts.posThr_update,:);
        pos_examples = pos_examples(randsample(end,min(opts.nPos_update,end)),:);
        
        neg_examples = gen_samples('uniform', targetLoc, opts.nNeg_update*2, opts, 2, 5);
        r = overlap_ratio(neg_examples,targetLoc);
        neg_examples = neg_examples(r<opts.negThr_update,:);
        neg_examples = neg_examples(randsample(end,min(opts.nNeg_update,end)),:);
        
        examples = [pos_examples; neg_examples];
        pos_idx = 1:size(pos_examples,1);
        neg_idx = (1:size(neg_examples,1)) + size(pos_examples,1);
        
        %%%$$$ 是否让模型记住插帧结�??
        feat_conv = mdnet_features_convX(net_conv, img, examples, opts); % img 为本�?
        total_pos_data{To} = feat_conv(:,:,:,pos_idx);
        total_neg_data{To} = feat_conv(:,:,:,neg_idx);
        
        success_frames = [success_frames, To];% 已经被成功检测到的帧
        if(numel(success_frames)>opts.nFrames_long)
            %队列形式更新,清空total_neg_data\total_neg_data之前的一些帧
            total_pos_data{success_frames(end-opts.nFrames_long)} = single([]);
        end
        if(numel(success_frames)>opts.nFrames_short)
            total_neg_data{success_frames(end-opts.nFrames_short)} = single([]);
        end
    else
        total_pos_data{To} = single([]);  % 本帧�?测失�?,不对正负区域记录特征
        total_neg_data{To} = single([]);
    end  
    %% Network update
    % 每隔10帧或者分数小�?0的时�? 
    if((mod(To,opts.update_interval)==0 || target_score<0) && To~=nFrames)
        if (target_score<0) % short-term update,基于score,选取�?后一个区间内的featuremap
            pos_data = cell2mat(total_pos_data(success_frames(max(1,end-opts.nFrames_short+1):end)));
        else % long-term update,基于interval.选取�?后一个区间内的featuremap
            pos_data = cell2mat(total_pos_data(success_frames(max(1,end-opts.nFrames_long+1):end)));
        end
        neg_data = cell2mat(total_neg_data(success_frames(max(1,end -opts.nFrames_short+1):end)));
        
        if (target_score<0)% 短时更新net.fc (Emergency renew)1
        net_fc = mdnet_finetune_hnm(net_fc,pos_data,neg_data,opts,...
            'maxiter',opts.maxiter_update,'learningRate',opts.learningRate_update);
        else %长时更细net.fc以及 net.G(Regular renew)!!
        [net_fc, net_G] = mdnet_finetune_hnm_update(net_fc,net_G,pos_data,neg_data,opts,...
            'maxiter',opts.maxiter_update,'learningRate',opts.learningRate_update);
        end
    end
    fprintf('.');
    if mod(To,30) == 0
        fprintf('%d\n',To);
    end

end

endd = toc;
duration = endd-startt;
fps = (nFrames) / duration;

end


function rect2 = expandSearchArea(rect,r,H,W)  % lefttop widh height
l1 = rect(1);
t1 = rect(2);
w1 = rect(3);
h1 = rect(4);
cx = l1 + (w1 -1)/2;
cy = t1 + (h1 -1)/2;
w2 = w1 * r;
h2 = h1 * r;
l2 = max(1,cx - (w2 - 1)/2);
t2 = max(1,cy - (h2 - 1)/2);

Wmax = W - l2 + 1;
Hmax = H - t2 + 1;
w2   = max(1,min(Wmax,w2));
h2   = max(1,min(Hmax,h2));function [ result ,Interp_bbox,Choice,th,fps] = run_VITAL_ADV3_7_1(imgSet, init_rect,localTh)

%%% 四中心算法，上一帧框、上一帧光流框(_1)、插帧框、插帧光流框(_5)
%%% 本算法目前需要插帧模型的辅助，目前仅仅在OTB集合上进行模拟

run ./matconvnet/matlab/vl_setupnn ;
addpath('./utils');
addpath('./models');
addpath('./vital');
addpath('./tracking');
addpath('./adv');           					%%  插帧算法、求光流算法



display = false;
global gpu;
gpu=true;

%conf = winconfig;
conf = config;
net=fullfile('./models/otbModel.mat');

%% Initialization
% fprintf('Initialization...\n');   

nFrames = length(imgSet);

img = imread(imgSet{1});
if(size(img,3)==1), img = cat(3,img,img,img); end
targetLoc = init_rect;
result = zeros(nFrames, 4); result(1,:) = targetLoc;
Interp_bbox = zeros(2*nFrames-1,4);Interp_bbox(1,:) = targetLoc;
interpCounter = 2; %always appears at the present position
targetScores = zeros(nFrames,1);
targetScores(1) = 2.0;
[net_conv, net_fc, opts] = mdnet_init(img, net);
[net_G, opts_net] = G_init();


CENTER_DELTA = opts.nSamples;



%% Train a bbox regressor
if(opts.bbreg)
    pos_examples = gen_samples('uniform_aspect', targetLoc, opts.bbreg_nSamples*10, opts, 0.3, 10);
    r = overlap_ratio(pos_examples,targetLoc);
    pos_examples = pos_examples(r>0.6,:);
    pos_examples = pos_examples(randsample(end,min(opts.bbreg_nSamples,end)),:); % an example of the  
    feat_conv = mdnet_features_convX(net_conv, img, pos_examples, opts); % multi-threaded
    X = permute(gather(feat_conv),[4,3,1,2]);
    X = X(:,:);
    bbox = pos_examples;
    bbox_gt = repmat(targetLoc,size(pos_examples,1),1);
    bbox_reg = train_bbox_regressor(X, bbox, bbox_gt);
end

%% Extract training examples
% fprintf('  extract features...\n');

% draw positive/negative samples
pos_examples = gen_samples('gaussian', targetLoc, opts.nPos_init*2, opts, 0.1, 5);
r = overlap_ratio(pos_examples,targetLoc);
pos_examples = pos_examples(r>opts.posThr_init,:);
pos_examples = pos_examples(randsample(end,min(opts.nPos_init,end)),:);

neg_examples = [gen_samples('uniform', targetLoc, opts.nNeg_init, opts, 1, 10);...
    gen_samples('whole', targetLoc, opts.nNeg_init, opts)];
r = overlap_ratio(neg_examples,targetLoc);
neg_examples = neg_examples(r<opts.negThr_init,:);
neg_examples = neg_examples(randsample(end,min(opts.nNeg_init,end)),:);

examples = [pos_examples; neg_examples];
pos_idx = 1:size(pos_examples,1);
neg_idx = (1:size(neg_examples,1)) + size(pos_examples,1);

% extract conv3 features
feat_conv = mdnet_features_convX(net_conv, img, examples, opts);
pos_data = feat_conv(:,:,:,pos_idx);
neg_data = feat_conv(:,:,:,neg_idx);


%% Learning CNN
% fprintf('  training cnn...\n');
%%%$$$ finetune with hard-minging ,训练与微调第�?�?,使得NET_FC获得来自第一帧的调节
net_fc = mdnet_finetune_hnm(net_fc,pos_data,neg_data,opts,...
    'maxiter',opts.maxiter_init,'learningRate',opts.learningRate_init);

net_G = G_pretrain(net_fc, net_G, pos_data, opts_net);


%% Prepare training data for online update
total_pos_data = cell(1,1,1,nFrames);
total_neg_data = cell(1,1,1,nFrames);

neg_examples = gen_samples('uniform', targetLoc, opts.nNeg_update*2, opts, 2, 5);
r = overlap_ratio(neg_examples,targetLoc);
neg_examples = neg_examples(r<opts.negThr_init,:);
neg_examples = neg_examples(randsample(end,min(opts.nNeg_update,end)),:);

examples = [pos_examples; neg_examples];
pos_idx = 1:size(pos_examples,1);
neg_idx = (1:size(neg_examples,1)) + size(pos_examples,1);
% 从第�?帧提取特�?
feat_conv = mdnet_features_convX(net_conv, img, examples, opts);
total_pos_data{1} = feat_conv(:,:,:,pos_idx);
total_neg_data{1} = feat_conv(:,:,:,neg_idx);

success_frames = 1;
trans_f = opts.trans_f;
scale_f = opts.scale_f;


tic;
startt = toc;

target_score = 2.8888888;
Choice(1)= 0.0;
th = -1;

%% Main loop
for To = 2:nFrames
    %% Whether need enhancement, judged by 'Local  Difference' M12011155
    optFlow = optF(imgSet,To,'frm');     %此处去计算TimeO-1的光�?
    %% $$$$$ 其实如何把光流到新的框做�?个小网络应该也能有不错的效果
    InterpSWITCH = false; % this variable is responsible for interpolation reinforcement
    OptRectSWITCH = true; % this variable is responsible for optical flow rect sample point enhancement
    
    
    %% %$$$ CENTER 1  targetLoc  
    
    %% %$$$ CENTER 2  newRect
    newRect = optShiftRect(targetLoc,optFlow);    
    
    %% %$$$ CENTER 3  targetLoc_Itp
    imgInterpLast = interpAlg(imgSet,To);%$
    if(size(imgInterpLast,3)==1), imgInterpLast = cat(3,imgInterpLast,imgInterpLast,imgInterpLast); end
    samples_Itp = gen_samples('gaussian', targetLoc, opts.nSamples, opts, trans_f, scale_f);%$
    %%% net_conv is the target network I have to worry about.
    feat_conv_Itp = mdnet_features_convX(net_conv, imgInterpLast, samples_Itp, opts);%%
    feat_fc_Itp = mdnet_features_fcX(net_fc, feat_conv_Itp, opts);%% 
    feat_fc_Itp = squeeze(feat_fc_Itp)';%%
    [scores_Itp,idx_Itp] = sort(feat_fc_Itp(:,2),'descend');  %%
    target_score_Itp = mean(scores_Itp(1:5));%%
    targetLoc_Itp = round(mean(samples_Itp(idx_Itp(1:5),:))); %%
   
    
    %% %$$$ CENTER 4  targetLoc_Itp_Opt
    optItpFlow = optF(imgSet,To,'itp');
    targetLoc_Itp_Opt = optShiftRect(targetLoc_Itp,optItpFlow);
    

    
    
    
    %% Estimation 下面�  ?始好好的跑检测的步骤
  
	samples1 = gen_samples('gaussian', targetLoc, opts.nSamples, opts, trans_f, scale_f);
    samples2 = gen_samples('gaussian', newRect, opts.nSamples, opts, trans_f, scale_f);
    samples3 = gen_samples('gaussian', targetLoc_Itp, opts.nSamples, opts, trans_f, scale_f);
    samples4 = gen_samples('gaussian', targetLoc_Itp_Opt, opts.nSamples, opts, trans_f, scale_f);
    samples = [samples1;samples2;samples3;samples4];
    
    img = imread(imgSet{To});
    if(size(img,3)==1), img = cat(3,img,img,img); end 
    
    
    
    % draw target candidates,按照高斯的方�?,在上�?帧附近采�?,并且利用函数mdnet_features_convX抽取他们的特�?
    feat_conv = mdnet_features_convX(net_conv, img, samples, opts);
    
    % evaluate the candidates ===> 结果计算的位�?
    feat_fc = mdnet_features_fcX(net_fc, feat_conv, opts);
    feat_fc = squeeze(feat_fc)';
    

    nCenter      = size(feat_fc,1)/CENTER_DELTA;
    idxMtrx      = zeros(nCenter,CENTER_DELTA);
    tarlocMtrx   = zeros(nCenter,4);
    tarScores    = zeros(nCenter,1);
    
    for k = 1:nCenter
       offset = CENTER_DELTA * (k-1);
       feat_fc_slice = feat_fc(offset+1:offset+CENTER_DELTA,:);
       samples_slice = samples(offset+1:offset+CENTER_DELTA,:);
       [scores,idx] = sort(feat_fc_slice(:,2),'descend');
       ts = mean(scores(1:5));
       tl = round(mean(samples_slice(idx(1:5),:)));
       idxMtrx(k,:) = idx + offset;
       tarlocMtrx(k,:) = tl; 
       tarScores(k,:) = ts;
    end
    [~,idxChannelChoice] = max(tarScores);
    targetLoc = tarlocMtrx(idxChannelChoice,:);
    target_score = tarScores(idxChannelChoice);
    
    % final target without regression
    result(To,:) = targetLoc;
    Interp_bbox(interpCounter,:) = targetLoc;
    targetScores(To) = target_score;
    % extend search space in case of failure 作用于前面采样步�?
    if(target_score<0)
        trans_f = min(1.5, 1.1*trans_f);
    else
        trans_f = opts.trans_f;
    end
    % if InterpSWITCH
    % bbox regression ###$$$ 这个可能是下面工作将要解决的问题
    if(opts.bbreg && target_score>0)
        X_ = permute(gather(feat_conv(:,:,:,idxMtrx(idxChannelChoice,1:5))),[4,3,1,2]);
        X_ = X_(:,:);
        bbox_ = samples(idxMtrx(idxChannelChoice,1:5),:);
        pred_boxes = predict_bbox_regressor(bbox_reg.model, X_, bbox_);%feature and old box to gett new one. RCNN
        result(To,:) = round(mean(pred_boxes,1));
        Interp_bbox(interpCounter,:) = round(mean(pred_boxes,1));
    end
    interpCounter = interpCounter + 1;
    %end
    %% Prepare training data  本图的追踪结果基�?上记�?
    if(target_score>0)
        pos_examples = gen_samples('gaussian', targetLoc, opts.nPos_update*2, opts, 0.1, 5);
        r = overlap_ratio(pos_examples,targetLoc);
        pos_examples = pos_examples(r>opts.posThr_update,:);
        pos_examples = pos_examples(randsample(end,min(opts.nPos_update,end)),:);
        
        neg_examples = gen_samples('uniform', targetLoc, opts.nNeg_update*2, opts, 2, 5);
        r = overlap_ratio(neg_examples,targetLoc);
        neg_examples = neg_examples(r<opts.negThr_update,:);
        neg_examples = neg_examples(randsample(end,min(opts.nNeg_update,end)),:);
        
        examples = [pos_examples; neg_examples];
        pos_idx = 1:size(pos_examples,1);
        neg_idx = (1:size(neg_examples,1)) + size(pos_examples,1);
        
        %%%$$$ 是否让模型记住插帧结�??
        feat_conv = mdnet_features_convX(net_conv, img, examples, opts); % img 为本�?
        total_pos_data{To} = feat_conv(:,:,:,pos_idx);
        total_neg_data{To} = feat_conv(:,:,:,neg_idx);
        
        success_frames = [success_frames, To];% 已经被成功检测到的帧
        if(numel(success_frames)>opts.nFrames_long)
            %队列形式更新,清空total_neg_data\total_neg_data之前的一些帧
            total_pos_data{success_frames(end-opts.nFrames_long)} = single([]);
        end
        if(numel(success_frames)>opts.nFrames_short)
            total_neg_data{success_frames(end-opts.nFrames_short)} = single([]);
        end
    else
        total_pos_data{To} = single([]);  % 本帧�?测失�?,不对正负区域记录特征
        total_neg_data{To} = single([]);
    end  
    %% Network update
    % 每隔10帧或者分数小�?0的时�? 
    if((mod(To,opts.update_interval)==0 || target_score<0) && To~=nFrames)
        if (target_score<0) % short-term update,基于score,选取�?后一个区间内的featuremap
            pos_data = cell2mat(total_pos_data(success_frames(max(1,end-opts.nFrames_short+1):end)));
        else % long-term update,基于interval.选取�?后一个区间内的featuremap
            pos_data = cell2mat(total_pos_data(success_frames(max(1,end-opts.nFrames_long+1):end)));
        end
        neg_data = cell2mat(total_neg_data(success_frames(max(1,end -opts.nFrames_short+1):end)));
        
        if (target_score<0)% 短时更新net.fc (Emergency renew)1
        net_fc = mdnet_finetune_hnm(net_fc,pos_data,neg_data,opts,...
            'maxiter',opts.maxiter_update,'learningRate',opts.learningRate_update);
        else %长时更细net.fc以及 net.G(Regular renew)!!这个地方也是本文的创新点 
        [net_fc, net_G] = mdnet_finetune_hnm_update(net_fc,net_G,pos_data,neg_data,opts,...
            'maxiter',opts.maxiNetter_update,'learningRate',opts.learningRate_update);
        end
    end
    fprintf('.');
    if mod(To,30) == 0
        fprintf('%d\n',To);
    end

end

endd = toc;
duration = endd-startt;
fps = (nFrames) / duration;

end


function rect2 = expandSearchArea(rect,r,H,W)  % lefttop widh height
l1 = rect(1);
t1 = rect(2);
w1 = rect(3);
h1 = rect(4);
cx = l1 + (w1 -1)/2;
cy = t1 + (h1 -1)/2;
w2 = w1 * r;
h2 = h1 * r;
l2 = max(1,cx - (w2 - 1)/2);
t2 = max(1,cy - (h2 - 1)/2);

Wmax = W - l2 + 1;
Hmax = H - t2 + 1;
w2   = max(1,min(Wmax,w2));
h2   = max(1,min(Hmax,h2));

rect2 = [l2;t2;w2;h2];
rect2 = round(rect2);
rect2 = rect2';
end

function res = channelizeScores(mat,nDelta,nRecord)
nGroupChannel = size(mat,1) / nDelta;
tmp = mat';
tmp = reshape(tmp,nRecord,nDelta,nGroupChannel);
res = permute(tmp,[2,1,3]);
end

rect2 = [l2;t2;w2;h2];
rect2 = round(rect2);
rect2 = rect2';
end

function res = channelizeScores(mat,nDelta,nRecord)
nGroupChannel = size(mat,1) / nDelta;
tmp = mat';
tmp = reshape(tmp,nRecord,nDelta,nGroupChannel);
res = permute(tmp,[2,1,3]);
end