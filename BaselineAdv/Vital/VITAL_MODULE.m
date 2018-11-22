classdef VITAL_MODULE
    %VITAL_MODULE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        targetLoc = [0,0,0,0];
        optS;
        trans_f ;
        scale_f ;
        net_conv;
        net_fc;
        net_G ;
        success_frames;
        opts_net;
       	total_pos_data;
     	total_neg_data;
        bbox_reg;
        To;
        nFrames;
    end
    
    methods
        function obj = VITAL_MODULE(imgSet, init_rect)           
%           obj.Property1 = inputArg1 + inputArg2;
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
            obj.nFrames = length(imgSet);
            img = imread(imgSet{1});
            if(size(img,3)==1), img = cat(3,img,img,img); end
            obj.targetLoc = init_rect;
            result = zeros(obj.nFrames, 4); result(1,:) = obj.targetLoc;
            [obj.net_conv, obj.net_fc, obj.optS] = mdnet_init(img, net);
            [obj.net_G , obj.opts_net] = G_init();
            %% Train a bbox regressor
            if(obj.optS.bbreg)
                pos_examples = gen_samples('uniform_aspect', obj.targetLoc, obj.optS.bbreg_nSamples*10, obj.optS, 0.3, 10);
                r = overlap_ratio(pos_examples,obj.targetLoc);
                pos_examples = pos_examples(r>0.6,:);
                pos_examples = pos_examples(randsample(end,min(obj.optS.bbreg_nSamples,end)),:);
                feat_conv = mdnet_features_convX(obj.net_conv, img, pos_examples, obj.optS); % multi-threaded

                X = permute(gather(feat_conv),[4,3,1,2]);
                X = X(:,:);
                bbox = pos_examples;
                bbox_gt = repmat(obj.targetLoc,size(pos_examples,1),1);
                obj.bbox_reg = train_bbox_regressor(X, bbox, bbox_gt);
            end

            %% Extract training examples
            % fprintf('  extract features...\n');
            % draw positive/negative samples
            pos_examples = gen_samples('gaussian', obj.targetLoc, obj.optS.nPos_init*2, obj.optS, 0.1, 5);
            r = overlap_ratio(pos_examples,obj.targetLoc);
            pos_examples = pos_examples(r>obj.optS.posThr_init,:);
            pos_examples = pos_examples(randsample(end,min(obj.optS.nPos_init,end)),:);

            neg_examples = [gen_samples('uniform', obj.targetLoc, obj.optS.nNeg_init, obj.optS, 1, 10);...
                gen_samples('whole', obj.targetLoc, obj.optS.nNeg_init, obj.optS)];
            r = overlap_ratio(neg_examples,obj.targetLoc);
            neg_examples = neg_examples(r<obj.optS.negThr_init,:);
            neg_examples = neg_examples(randsample(end,min(obj.optS.nNeg_init,end)),:);

            examples = [pos_examples; neg_examples];
            pos_idx = 1:size(pos_examples,1);
            neg_idx = (1:size(neg_examples,1)) + size(pos_examples,1);

            % extract conv3 features
            feat_conv = mdnet_features_convX(obj.net_conv, img, examples, obj.optS);
            pos_data = feat_conv(:,:,:,pos_idx);
            neg_data = feat_conv(:,:,:,neg_idx);


            %% Learning CNN
            % fprintf('  training cnn...\n');
            obj.net_fc = mdnet_finetune_hnm(obj.net_fc,pos_data,neg_data,obj.optS,...
                'maxiter',obj.optS.maxiter_init,'learningRate',obj.optS.learningRate_init);
            obj.net_G = G_pretrain(obj.net_fc, obj.net_G, pos_data, obj.opts_net);
            %% Prepare training data for online update
            obj.total_pos_data = cell(1,1,1,obj.nFrames);
            obj.total_neg_data = cell(1,1,1,obj.nFrames);
            neg_examples = gen_samples('uniform', obj.targetLoc, obj.optS.nNeg_update*2, obj.optS, 2, 5);
            r = overlap_ratio(neg_examples,obj.targetLoc);
            neg_examples = neg_examples(r<obj.optS.negThr_init,:);
            neg_examples = neg_examples(randsample(end,min(obj.optS.nNeg_update,end)),:);
            examples = [pos_examples; neg_examples];
            pos_idx = 1:size(pos_examples,1);
            neg_idx = (1:size(neg_examples,1)) + size(pos_examples,1);
            feat_conv = mdnet_features_convX(obj.net_conv, img, examples, obj.optS);
            obj.total_pos_data{1} = feat_conv(:,:,:,pos_idx);
            obj.total_neg_data{1} = feat_conv(:,:,:,neg_idx);
            obj.success_frames = 1;
            obj.trans_f = obj.optS.trans_f;
            obj.scale_f = obj.optS.scale_f;
            obj.To = 1;
        end
        
        
        function resRect = trackNext(obj,imgName,lastRect)
            obj.To  = obj.To + 1;
            img = imread(imgName);
            if(size(img,3)==1), img = cat(3,img,img,img); end 
            %% Estimation
            % draw target candidates
            samples = gen_samples('gaussian', lastRect, obj.optS.nSamples, obj.optS, obj.trans_f, obj.scale_f);
            feat_conv = mdnet_features_convX(obj.net_conv, img, samples, obj.optS);
            % evaluate the candidates
            feat_fc = mdnet_features_fcX(obj.net_fc, feat_conv, obj.optS);
            feat_fc = squeeze(feat_fc)';
            [scores,idx] = sort(feat_fc(:,2),'descend');
            target_score = mean(scores(1:5));
            obj.targetLoc = round(mean(samples(idx(1:5),:)));

            % final target
            resRect = obj.targetLoc;

            % extend search space in case of failure
            if(target_score<0)
                obj.trans_f = min(1.5, 1.1*obj.trans_f);
            else
                obj.trans_f = obj.optS.trans_f;
            end

            % bbox regression
            if(obj.optS.bbreg && target_score>0)
                X_ = permute(gather(feat_conv(:,:,:,idx(1:5))),[4,3,1,2]);
                X_ = X_(:,:);
                bbox_ = samples(idx(1:5),:);
                pred_boxes = predict_bbox_regressor(obj.bbox_reg.model, X_, bbox_);
                resRect = round(mean(pred_boxes,1));
            end

            %% Prepare training data
            if(target_score>0)
                pos_examples = gen_samples('gaussian', obj.targetLoc, obj.optS.nPos_update*2, obj.optS, 0.1, 5);
                r = overlap_ratio(pos_examples,obj.targetLoc);
                pos_examples = pos_examples(r>obj.optS.posThr_update,:);
                pos_examples = pos_examples(randsample(end,min(obj.optS.nPos_update,end)),:);

                neg_examples = gen_samples('uniform', obj.targetLoc, obj.optS.nNeg_update*2, obj.optS, 2, 5);
                r = overlap_ratio(neg_examples,obj.targetLoc);
                neg_examples = neg_examples(r<obj.optS.negThr_update,:);
                neg_examples = neg_examples(randsample(end,min(obj.optS.nNeg_update,end)),:);

                examples = [pos_examples; neg_examples];
                pos_idx = 1:size(pos_examples,1);
                neg_idx = (1:size(neg_examples,1)) + size(pos_examples,1);

                feat_conv = mdnet_features_convX(obj.net_conv, img, examples, obj.optS);
                obj.total_pos_data{obj.To} = feat_conv(:,:,:,pos_idx);
                obj.total_neg_data{obj.To} = feat_conv(:,:,:,neg_idx);

                obj.success_frames = [obj.success_frames, obj.To];
                if(numel(obj.success_frames)>obj.optS.nFrames_long)
                    obj.total_pos_data{obj.success_frames(end-obj.optS.nFrames_long)} = single([]);
                end
                if(numel(obj.success_frames)>obj.optS.nFrames_short)
                    obj.total_neg_data{obj.success_frames(end-obj.optS.nFrames_short)} = single([]);
                end
            else
                obj.total_pos_data{obj.To} = single([]);
                obj.total_neg_data{obj.To} = single([]);
            end
            %% Network update
            if((mod(obj.To,obj.optS.update_interval)==0 || target_score<0) && obj.To~=obj.nFrames)
                if (target_score<0) % short-term update
                    pos_data = cell2mat(obj.total_pos_data(obj.success_frames(max(1,end-obj.optS.nFrames_short+1):end)));
                else % long-term update
                    pos_data = cell2mat(obj.total_pos_data(obj.success_frames(max(1,end-obj.optS.nFrames_long+1):end)));
                end
                neg_data = cell2mat(obj.total_neg_data(obj.success_frames(max(1,end-obj.optS.nFrames_short+1):end)));
                if (target_score<0)
                obj.net_fc = mdnet_finetune_hnm(obj.net_fc,pos_data,neg_data,obj.optS,...
                    'maxiter',obj.optS.maxiter_update,'learningRate',obj.optS.learningRate_update);
                else
                [obj.net_fc, obj.net_G] = mdnet_finetune_hnm_update(obj.net_fc,obj.net_G,pos_data,neg_data,obj.optS,...
                    'maxiter',obj.optS.maxiter_update,'learningRate',obj.optS.learningRate_update);
                end
            end            
        end
    end
end

