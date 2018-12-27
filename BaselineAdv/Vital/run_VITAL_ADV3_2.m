function [ result ,Interp_bbox,MDEGArr,th,fps] = run_VITAL_ADV3_2(imgSet, init_rect,ratio)
%% The first amendment for the advanced VITAL. In order to generate a better
%% demo, we fix this function by letting it record the result bbox of the 
%% procedure that manipulates interpolated frames  
%%%$$$ 全局帧差百分比法
%% 融合策略 更新策略 搞清楚每一部分输入是什么输出是什么，对每一帧插帧以及不插帧，都进行判断与不同的处理运算
%%% THresh Test
%%%%  THresh Test -- rate by argument
run ./matconvnet/matlab/vl_setupnn ;
addpath('./utils');
addpath('./models');
addpath('./vital');
addpath('./tracking');
addpath('./adv');



display = false;
global gpu;
gpu=true;
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
%%%$$$ finetune with hard-minging ,训练与微调第一帧,使得NET_FC获得来自第一帧的调节
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
% 从第一帧提取特征
feat_conv = mdnet_features_convX(net_conv, img, examples, opts);
total_pos_data{1} = feat_conv(:,:,:,pos_idx);
total_neg_data{1} = feat_conv(:,:,:,neg_idx);

success_frames = 1;
trans_f = opts.trans_f;
scale_f = opts.scale_f;


tic;
startt = toc;

target_score = 2.8888888;
%%%%%%%%%%%%%%%%%%%%%%%%
%operateFlags = true(1,nFrames);
%operateFlags = false(1,nFrames);
%%%%%%%%%%%%%%%%%%%%%%%%


%% calculate the MDE-Global  : MDEG
fprintf('MDE Calculatio\n');

for x = 2:nFrames
    %% Whether need enhancement, judged by 'Difference' M11251815
    thisImg = imread(imgSet{x});
    lastImg = imread(imgSet{x-1});
    
    [h,w,c] = size(thisImg);
    if(c ==1)
            thisY = thisImg;
            lastY = lastImg;
    else
            thisY = rgb2ycbcr(thisImg);
            thisY = thisY(:,:,1);
            lastY = rgb2ycbcr(lastImg);
            lastY = lastY(:,:,1);
    end
    diff = abs(thisY-lastY);
    MDE = sum(sum(diff))/(w*h);
    MDEGArr(x) = MDE;
    if mod(x,100)==0
        fprintf('-');
    end
end
%%%
%  ratio -- （0,1）
MDEThresh = prctile(MDEGArr,(100-ratio*100)); % conf.RateNotInterp Partial not use interpMDEArr
operateFlags = MDEGArr > MDEThresh;
fprintf('>\n');
th = MDEThresh;
%% Main loop
for To = 2:nFrames
    OF = operateFlags(To); %%%% This is the interface
   
    %% for enhancement
    if OF 
        imgInterpLast = interpAlg(imgSet,To);%$
        if(size(imgInterpLast,3)==1), imgInterpLast = cat(3,imgInterpLast,imgInterpLast,imgInterpLast); end
        samples_Itp = gen_samples('gaussian', targetLoc, opts.nSamples, opts, trans_f, scale_f);%$
        feat_conv_Itp = mdnet_features_convX(net_conv, imgInterpLast, samples_Itp, opts);%%
        feat_fc_Itp = mdnet_features_fcX(net_fc, feat_conv_Itp, opts);%%
        feat_fc_Itp = squeeze(feat_fc_Itp)';%%
        [scores_Itp,idx_Itp] = sort(feat_fc_Itp(:,2),'descend');  %%
        target_score_Itp = mean(scores_Itp(1:5));%%
        targetLoc_Itp = round(mean(samples_Itp(idx_Itp(1:5),:))); %%
    else
        %% Take t-1 as the silent res
        target_score_Itp = target_score;%%
        targetLoc_Itp = targetLoc; %%
    end
    
    %% end the enhancement
    if OF
        Interp_bbox(interpCounter,:) = targetLoc_Itp;
        interpCounter = interpCounter + 1;
    else
        Interp_bbox(interpCounter,:) = targetLoc;
        interpCounter = interpCounter + 1;
    end
    
    
    
    %% Estimation 下面开始好好的跑检测的步骤
    if OF
        if target_score_Itp > targetScores(To-1) && targetScores(To-1) > 0
            samples1 = gen_samples('gaussian', targetLoc, opts.nSamples, opts, trans_f, scale_f);
            samples2 = gen_samples('gaussian', targetLoc_Itp, opts.nSamples, opts, trans_f, scale_f);
            samples = [samples1;samples2];
        elseif target_score_Itp > targetScores(To-1) && targetScores(To-1) < 0
            samples2 = gen_samples('gaussian', targetLoc_Itp, opts.nSamples, opts, trans_f, scale_f);
            samples = samples2;
        else
            samples1 = gen_samples('gaussian', targetLoc, opts.nSamples, opts, trans_f, scale_f);
            samples = samples1;
        end
    else
        samples1 = gen_samples('gaussian', targetLoc, opts.nSamples, opts, trans_f, scale_f);
        samples = samples1;
    end
    
    img = imread(imgSet{To});
    if(size(img,3)==1), img = cat(3,img,img,img); end 
    
    
    
    % draw target candidates,按照高斯的方法,在上一帧附近采样,并且利用函数mdnet_features_convX抽取他们的特征
    feat_conv = mdnet_features_convX(net_conv, img, samples, opts);
    
    % evaluate the candidates ===> 结果计算的位置
    feat_fc = mdnet_features_fcX(net_fc, feat_conv, opts);
    feat_fc = squeeze(feat_fc)';
    [scores,idx] = sort(feat_fc(:,2),'descend'); % neg pos
    target_score = mean(scores(1:5));
    targetLoc = round(mean(samples(idx(1:5),:))); % 结果是前五名框的平均
    
    

    % final target without regression
    result(To,:) = targetLoc;
    Interp_bbox(interpCounter,:) = targetLoc;
    targetScores(To) = target_score;
    % extend search space in case of failure 作用于前面采样步骤
    if(target_score<0)
        trans_f = min(1.5, 1.1*trans_f);
    else
        trans_f = opts.trans_f;
    end

    % if OF
    % bbox regression ###$$$ 这个可能是下面工作将要解决的问题
    if(opts.bbreg && target_score>0)
        X_ = permute(gather(feat_conv(:,:,:,idx(1:5))),[4,3,1,2]);
        X_ = X_(:,:);
        bbox_ = samples(idx(1:5),:);
        pred_boxes = predict_bbox_regressor(bbox_reg.model, X_, bbox_);%feature and old box to gett new one. RCNN
        result(To,:) = round(mean(pred_boxes,1));
        Interp_bbox(interpCounter,:) = round(mean(pred_boxes,1));
    end
    interpCounter = interpCounter + 1;
    %end
   
    %% Prepare training data  本图的追踪结果基础上记录
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
        
        %%%$$$ 是否让模型记住插帧结果?
        feat_conv = mdnet_features_convX(net_conv, img, examples, opts); % img 为本帧
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
        total_pos_data{To} = single([]);  % 本帧检测失败,不对正负区域记录特征
        total_neg_data{To} = single([]);
    end  
    %% Network update
    % 每隔10帧或者分数小于0的时候 
    if((mod(To,opts.update_interval)==0 || target_score<0) && To~=nFrames)
        if (target_score<0) % short-term update,基于score,选取最后一个区间内的featuremap
            pos_data = cell2mat(total_pos_data(success_frames(max(1,end-opts.nFrames_short+1):end)));
        else % long-term update,基于interval.选取最后一个区间内的featuremap
            pos_data = cell2mat(total_pos_data(success_frames(max(1,end-opts.nFrames_long+1):end)));
        end
        neg_data = cell2mat(total_neg_data(success_frames(max(1,end -opts.nFrames_short+1):end)));
        
        if (target_score<0)% 短时更新net.fc (Emergency renew)1
        net_fc = mdnet_finetune_hnm(net_fc,pos_data,neg_data,opts,...
            'maxiter',opts.maxiter_update,'learningRate',opts.learningRate_update);
        else %长时更细net.fc以及 net.G(Regular renew)
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