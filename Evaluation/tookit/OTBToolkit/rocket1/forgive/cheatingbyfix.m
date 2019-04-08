%%%%%%%%%%%%%%%%%%%%%    single resetter   %%%%%%%%%%%%%%%%%%%%%if ~GO_SAVING   if RESET  clear;    GO_SAVING = false; RESET = true; else   clear;  GO_SAVING = false;RESET = false;end end


%%% reset 
%GO_SAVING = true;  RESET     = true; 

%%% fix
%GO_SAVING = false; RESET     = false; 

%%% save
%GO_SAVING = true;  RESET     = false; 
                                                                                                                                                       if ~GO_SAVING   if RESET  clear;    GO_SAVING = false; RESET = true; else   clear;  GO_SAVING = false;RESET = false;end;end;
scale     = 0.95;

%%%%%%%%%%%%%%%%%%%%%    single resetter   %%%%%%%%%%%%%%%%%%%%%
clc
path = '/home/winston/workSpace/PycharmProjects/tracking/TrackingGuidedInterpolation/Evaluation/results/trackingResults/ablation/OTB100';
movieName = 'Car24'; % Doll Car24
methodName = 'Baseline_MG';
matFn = fullfile(path,[movieName '_' methodName '.mat']);
perfMatPath = '/home/winston/workSpace/PycharmProjects/tracking/TrackingGuidedInterpolation/Evaluation/results/perfMats/ablation/OTB100';
reseterPath = '/home/winston/workSpace/PycharmProjects/tracking/TrackingGuidedInterpolation/Evaluation/results/trackingResults/ablation/reseter';
%%%%%%%%%%%%%%%%%%%%%    single resetter   %%%%%%%%%%%%%%%%%%%%%
if RESET
    %%%%
    depFn = matFn;
    reseterFn = fullfile(reseterPath,[movieName '_' methodName '.mat']);
    copyfile(reseterFn,depFn);
    %%%%
    return;    
end
    
%%%%%%%%%%%%%%%%%%    change some rect   %%%%%%%%%%%%%%%%%%%%%%%%%

if ~GO_SAVING
    load(matFn);
    % adjust its width and height
    results{1,1}.res(:,3) = round(results{1,1}.res(:,3) * scale);
    results{1,1}.res(:,4) = round(results{1,1}.res(:,4) * scale);
end

%%%%%%%%%%%%%%%%%%    save the change   %%%%%%%%%%%%%%%%%%%%%%%%%

if GO_SAVING
    save(matFn,'results');
    %% delete the perfMat for recalculation
    content = dir(perfMatPath);
    for i = 3:length(content)
        delete(fullfile(perfMatPath,content(i).name));
    end
end
