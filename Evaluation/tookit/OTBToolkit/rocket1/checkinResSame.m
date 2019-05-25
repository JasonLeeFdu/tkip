path1 = '/home/winston/workSpace/PycharmProjects/tracking/TrackingGuidedInterpolation/Evaluation/results/ACMMM/';
path2 = '/home/winston/workSpace/PycharmProjects/tracking/TrackingGuidedInterpolation/Evaluation/results/FourCentersItpOpt_BestPerf22222/';

files1 = dir(path1); files1 = files1(3:end);
files2 = dir(path2); files2 = files2(3:end);

flag = true;

for i = 1:length(files1)
   load(fullfile(path1,files1(i).name));
   res1 = results{1,1}.res;
   
   load(fullfile(path2,files2(i).name));
   res2 = results{1,1}.res;
   if ~all(all(res1==res2))
        flag = false;break;       
   end
end

disp('End');disp(flag);


