path1 = '/home/winston/workSpace/PycharmProjects/tracking/TrackingGuidedInterpolation/Datasets/OriginalInterp2/OTB100/Matrix/img';
path2 = '/home/winston/workSpace/PycharmProjects/tracking/TrackingGuidedInterpolation/Datasets/OriginalInterp2/OTB100(without TSL)/Matrix/img';
files = dir(path1);
files = files(3:end);
res = 'res.avi';
out = VideoWriter(res);
out.FrameRate = 25;
out.Quality = 95;
open(out);
img = imread(fullfile(path1,'0001.jpg'));
[h,w,c] = size(img);

for i = 1:length(files)
    img1 = imread(fullfile(path1,files(i).name));
    img2 = imread(fullfile(path2,files(i).name));
    interv = zeros(h,5,3);
    i
    if mod(i,2) == 0
        interv = ones(h,5,3)*255;
    end
    
    frame  = cat(2,img1,interv,img2);
    frame = insertText(frame,[3,3],['#' num2str(i)],'FontSize',45,'TextColor','yellow','BoxOpacity',0.0);
     cong+    writeVideo(out, frame);
end


close(out);
