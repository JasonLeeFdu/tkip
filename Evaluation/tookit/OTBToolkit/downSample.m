
tarDir = '/home/winston/workSpace/PycharmProjects/tracking/TrackingGuidedInterpolation/Evaluation/results/trackingResults/OriginalInterp2/OTB50';
tarList = dir(tarDir);
dsRate = 2;

for k = 4:length(tarList)
    tarFile = tarList(k);
    load(fullfile(tarDir,tarFile.name));
    if all(size(results{1, 1}.res) == size(results{1, 1}.anno))
        fprintf('%s is correct and thus ignored\n',tarFile.name);
    else
        % deal with it
        height = size(results{1,1}.res,1);
        idxChoice = 1:dsRate:height;
        results{1,1}.res = results{1,1}.res(idxChoice,:);
        if all(size(results{1, 1}.res) == size(results{1, 1}.anno))
            save(fullfile(tarDir,tarFile.name),'results');
            fprintf('FILE: %s is now fixed! \n',tarFile.name);      
        else
             fprintf('FILE: %s is broken! \n',tarFile.name);
             exit(-1);
        end
    end
    
end