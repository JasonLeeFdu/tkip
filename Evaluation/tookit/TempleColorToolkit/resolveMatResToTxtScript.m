path = '/home/winston/workSpace/PycharmProjects/tracking/TrackingGuidedInterpolation/Evaluation/tookit/TempleColorToolkit/results/CCOT/';
AlgName = 'CCOT';
files = dir(path);
files = files(3:end);

for idx = 1:length(files)
    fn = files(idx).name;
    poses = strfind(fn,'_');
    pivotStart = poses(2)+1; % 8 
    poses = strfind(fn,'.');
    pivotEnd = poses(1)-1;
    ResFn = [fn(pivotStart:pivotEnd) '_' AlgName '.txt'];
    load(fullfile(path,fn));
    dlmwrite(fullfile(path,ResFn), results{1,1}.res);
    
    
end

