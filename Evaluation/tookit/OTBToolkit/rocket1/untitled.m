% %% adjust the Original OTB100 VITAL results' structure
% path = '/home/winston/workSpace/PycharmProjects/tracking/TrackingGuidedInterpolation/Evaluation/results/trackingResults/Original/OTB100';
% fns = dir(path);
% 
% for i = 3:length(fns)
%     results = {}; 
%     resultsOri = {};
%     fn = fns(i).name;
%     srcPath = fullfile(path,fn);
%     load(srcPath);
% 
%     if ~isempty(resultsOri)
%         results=resultsOri;
%         save(srcPath,'results');
%         disp([fn 'is finished!']);
%     else
%         disp([fn 'is already done!']);
%     end
% end

%% Produce the Diff Movie

movieNames = {'MotorRolling','Lemming'};
moviePath  = '/home/winston/workSpace/PycharmProjects/tracking/TrackingGuidedInterpolation/Datasets/Original/OTB100';
ResPath    = '/home/winston/Desktop';
clipTime   = 8;
fps        = 25;
%%%%%%%%%%%%%%%%%%%%%%%%%%


%% STEP 1: Let's make the video


for i = 1:length(movieNames)
    movieClipPath = fullfile(moviePath,movieNames{i},'img');
    imgSet   = dir(movieClipPath);
    % init the movie writer
	out = VideoWriter(fullfile(ResPath,strcat(movieNames{i},'_diff.avi')));
    out.FrameRate = 25;
    out.Quality = 95;
    open(out);
    img = imread(fullfile(movieClipPath,imgSet(3).name));
    [h,w,c] = size(img);
    for j = 3:clipTime*fps
    % compute diff and concate that with the origin, then write it to the
    % movie
        if j == 3
            img = imread(fullfile(movieClipPath,imgSet(j).name));
            diff = zeros(h,w,3);
            st   = 0;
        else
            img = imread(fullfile(movieClipPath,imgSet(j).name));
            imgLast = imread(fullfile(movieClipPath,imgSet(j-1).name));
            imgY = rgb2ycbcr(img);
            imgY = imgY(:,:,1);
            imgLastY = rgb2ycbcr(imgLast);
            imgLastY = imgLastY(:,:,1);
            diff = abs(imgY - imgLastY);
            st   = sum(sum(diff));
            st   = st / (h*w);            
            diff = repmat(diff,[1,1,3]);
        end
    	canvas = cat(2,img,diff);
        %% insert MDE of every frame
        canvas = insertText(canvas,[20 20],num2str(st),'FontSize',28,'TextColor','red','BoxOpacity',0.0);
        writeVideo(out, canvas);
    end
    close(out);
end
disp('FINISHED MOVIES');

%% STEP 2: draw the MDE line

