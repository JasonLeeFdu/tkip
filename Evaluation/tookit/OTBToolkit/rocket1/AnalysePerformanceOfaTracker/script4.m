path1 = '/home/winston/workSpace/PycharmProjects/tracking/TrackingGuidedInterpolation/Datasets/OriginalInterp2/OTB100';
path2 = '/home/winston/workSpace/PycharmProjects/tracking/TrackingGuidedInterpolation/Datasets/OriginalInterp2/OTB100(without TSL)';
threshU = 33;
threshD = -23;

vn = 'MotorRolling';
files1 = dir(fullfile(path1,vn,'img'));
files2 = dir(fullfile(path2,vn,'img'));

files1 =  files1(3:end);
files2 =  files2(3:end);


totalLen = length(files1);



for i = 2:2:totalLen-1

img1 = imread(fullfile(path1,vn,'img',sprintf('%04d.jpg',i)));
img2 = imread(fullfile(path2,vn,'img',sprintf('%04d.jpg',i)));
PSNR = psnr(img1,img2);
if PSNR < threshU && PSNR > threshD
   i 
   PSNR
   disp('================');
end
    

    
end
    


