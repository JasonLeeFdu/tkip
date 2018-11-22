%% adjust the Original OTB100 VITAL results' structure
path = '/home/winston/workSpace/PycharmProjects/tracking/TrackingGuidedInterpolation/Evaluation/results/trackingResults/Original/OTB100';
fns = dir(path);

for i = 3:length(fns)
    results = {}; 
    resultsOri = {};
    fn = fns(i).name;
    srcPath = fullfile(path,fn);
    load(srcPath);

    if ~isempty(resultsOri)
        results=resultsOri;
        save(srcPath,'results');
        disp([fn 'is finished!']);
    else
        disp([fn 'is already done!']);
    end
end



















