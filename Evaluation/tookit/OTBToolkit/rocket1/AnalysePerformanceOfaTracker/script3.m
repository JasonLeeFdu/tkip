path = '/home/winston/workSpace/PycharmProjects/tracking/TrackingGuidedInterpolation/Datasets/OriginalInterp2/OTB100';

vns = dir(path);

vns = vns(3:end);

for i = 1:length(vns)
   vn  = vns(i).name ;
   imgs = dir(fullfile(path,vn)); imgs = imgs(3:end);
   % 
   mkdir(fullfile(path,vn,'img'));  
   for j = 1:length(imgs)
    movefile(fullfile(path,vn,imgs(j).name), fullfile(path,vn,'img',imgs(j).name));        
   end
   
    fprintf('.');
end




















