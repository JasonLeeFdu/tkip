function VITAL_ADV3_6_1__wrapper

%%% 对比实验，上一帧+光流移动框，为铆钉点。  然后不是“整体”的前五名取平均，而是两个中心分别取前五，然后两中心二选一
%%%$$$ 上一帧+光流移动框 无阈值 两中心取其一

[handle, imagePath, region] = vot('rectangle');
tmp = mfilename('fullpath');
tmpPoses = strfind(tmp,'/');
basePath = tmp(1:tmpPoses(end-1));

runCommand = strcat(basePath,'matconvnet/matlab/vl_setupnn');
run (runCommand);

addpath(basePath);
addpath(strcat(basePath,'utils'));
addpath(strcat(basePath,'models'));
addpath(strcat(basePath,'vital'));
addpath(strcat(basePath,'tracking'));
addpath(strcat(basePath,'adv'));           					%%  插帧算法、求光流算法


nFrames = 10000;
display = false;
global gpu;
gpu=true;
conf = config;
net=fullfile(strcat(basePath,'models/otbModel.mat'));

%% Initialization
% fprintf('Initialization...\n');   


try
    % Simple check for Octave environment
    OCTAVE_VERSION;
    rand('seed', sum(clock));
    pkg load image;
catch
    RandStream.setGlobalStream(RandStream('mt19937ar', 'Seed', sum(clock)));
end



img = imread(imagePath);
if(size(img,3)==1), img = cat(3,img,img,img); end
targetLoc = region;
interpCounter = 2; %always appears at the present position

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
target_score = 2.8888888;




To = 2; %% paoguangliu
%% Main loop
while true
    %%% 获取关于VOT的信息--Connection1 
    [handle, image] = handle.frame(handle);

    if isempty(image)
        break;
    end;
    %% Whether need enhancement, judged by 'Local  Difference' M12011155
    %optFlow = optF(image,To,'frm');     %此处去计算TimeO-1的光流
    %optFlow = optF(image,To,'frm');     %此处去计算TimeO-1的光�?
    
    %%%$$$
    %%%￥￥￥optFlow = optFVOT(image);     %此处去计算TimeO-1的光流
    optFlow = optF(image,-999,'itp');
    %% $$$$$ 其实如何把光流到新的框做�?个小网络应该也能有不错的效果
    InterpSWITCH = false; % this variable is responsible for interpolation reinforcement
    OptRectSWITCH = true; % this variable is responsible for optical flow rect sample point enhancement
    
    
    %% %$$$ CENTER 1  targetLoc  
    
    %% %$$$ CENTER 2  newRect
    newRect = optShiftRect(targetLoc,optFlow);    
    
    %% %$$$ CENTER 3  targetLoc_Itp
    %%%$$$
    imgInterpLast = interpAlg(image,-999);%$
    
    
    
    if(size(imgInterpLast,3)==1), imgInterpLast = cat(3,imgInterpLast,imgInterpLast,imgInterpLast); end
    samples_Itp = gen_samples('gaussian', targetLoc, opts.nSamples, opts, trans_f, scale_f);%$
    feat_conv_Itp = mdnet_features_convX(net_conv, imgInterpLast, samples_Itp, opts);%%
    feat_fc_Itp = mdnet_features_fcX(net_fc, feat_conv_Itp, opts);%% 
    feat_fc_Itp = squeeze(feat_fc_Itp)';%%
    [scores_Itp,idx_Itp] = sort(feat_fc_Itp(:,2),'descend');  %%
    target_score_Itp = mean(scores_Itp(1:5));%%
    targetLoc_Itp = round(mean(samples_Itp(idx_Itp(1:5),:))); %%
   
    
    %% %$$$ CENTER 4  targetLoc_Itp_Opt
    optItpFlow = optF(imgSet,-999,'itp');
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
   
    % **********************************
    % VOT: Report position for frame
    % **********************************
    %targetLoc = [110.0 110.0 110.0 110.0];
    targetLoc = double(targetLoc);
    %dlmwrite('~/Desktop/aa/fd',targetLoc,'-append','roffset',1);
    handle = handle.report(handle, targetLoc, target_score);
    To = To + 1;
end

% **********************************
% VOT: Output the results
% **********************************
handle.quit(handle);

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