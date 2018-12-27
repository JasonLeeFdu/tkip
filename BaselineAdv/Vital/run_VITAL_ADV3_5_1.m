function [ result ,Interp_bbox,MDEGArr,th,fps] = run_VITAL_ADV3_5_1(imgSet, init_rect,localTh)

%%%对比实验，此处，仅有上一帧的原始框作为该帧的铆钉点
%% DEPRECATED!!!效果还不如原来的算法 ORI，废止不用，试验中用Ori代替
run ./matconvnet/matlab/vl_setupnn ;
addpath('./utils');
addpath('./models');
addpath('./vital');
addpath('./tracking');
display = false;
global gpu;
gpu=true;

net=fullfile('./models/otbModel.mat');

%% Initialization
% fprintf('Initialization...\n');

nFrames = length(imgSet);

img = imread(imgSet{1});
if(size(img,3)==1), img = cat(3,img,img,img); end
targetLoc = init_rect;
result = zeros(nFrames, 4); result(1,:) = targetLoc;

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

%% Initialize displayots
if display
    figure(2);
    set(gcf,'Position',[200 100 600 400],'MenuBar','none','ToolBar','none');
    
    hd = imshow(img,'initialmagnification','fit'); hold on;
    rectangle('Position', targetLoc, 'EdgeColor', [1 0 0], 'Linewidth', 3);
    set(gca,'position',[0 0 1 1]);
    
    text(10,10,'1','Color','y', 'HorizontalAlignment', 'left', 'FontWeight','bold', 'FontSize', 30);
    hold off;
    drawnow;
end

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
%% Main loop
for To = 2:nFrames
    img = imread(imgSet{To});
    if(size(img,3)==1), img = cat(3,img,img,img); end 
    %% Estimation 下面开始好好的跑检测的步骤
    % draw target candidates,按照高斯的方法,在上一帧附近采样,并且利用函数mdnet_features_convX抽取他们的特征
	%%%$$$ 2 times the samples
    samples = gen_samples('gaussian', targetLoc, opts.nSamples*2, opts, trans_f, scale_f);
    
    feat_conv = mdnet_features_convX(net_conv, img, samples, opts);
    
    % evaluate the candidates === > 结果计算的位置
    feat_fc = mdnet_features_fcX(net_fc, feat_conv, opts);
    feat_fc = squeeze(feat_fc)';
    [scores,idx] = sort(feat_fc(:,2),'descend'); % neg pos
    target_score = mean(scores(1:5));
    targetLoc = round(mean(samples(idx(1:5),:))); % 结果是前五名框的平均
    
    % final target
    result(To,:) = targetLoc;
    
    % extend search space in case of failure 作用于前面采样步骤
    if(target_score<0)
        trans_f = min(1.5, 1.1*trans_f);
    else
        trans_f = opts.trans_f;
    end
    
    % bbox regression
    if(opts.bbreg && target_score>0)
        %% Actually, 'idx' contains the net_fc's ranking judgement
        X_ = permute(gather(feat_conv(:,:,:,idx(1:5))),[4,3,1,2]);
        X_ = X_(:,:);
        bbox_ = samples(idx(1:5),:);
        pred_boxes = predict_bbox_regressor(bbox_reg.model, X_, bbox_);%feature and old box to gett new one. RCNN
        result(To,:) = round(mean(pred_boxes,1));
    end
    
    %% Prepare training data
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
        
        feat_conv = mdnet_features_convX(net_conv, img, examples, opts);
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
        
        if (target_score<0)% 短时更新net.fc (Emergency renew)
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

Interp_bbox = -565;
MDEGArr = -565;
th = -565;
end





