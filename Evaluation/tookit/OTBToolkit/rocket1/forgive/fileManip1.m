path = '/home/winston/workSpace/PycharmProjects/tracking/TrackingGuidedInterpolation/Evaluation/tookit/TempleColorToolkit/results/DSLT';
path2 = '/home/winston/workSpace/PycharmProjects/tracking/TrackingGuidedInterpolation/Evaluation/results/trackingResults/ablation/Our Propose Proto VITAL_ADV';
files = dir(path);
files = files(3:end);
fnSet = cell(1,0);
for i = 1:length(files)
    subFn = files(i).name;
    if isempty(findstr('FLT',subFn) )
        continue;
    else   
        oriName    = fullfile(path,subFn);    
        newMatName = [oriName(1:end -7) 'DSLT.txt'];

        
        movefile(oriName,newMatName);
    end   
   

end


newToken = ''; % copyfile([sourcePath,'\',fileList(k).name],targetPath)



% 
% for i = 1:length(files)
%     subFn = files(i).name;
%     if isempty(findstr('_VITAL_Adv.mat',subFn) )
%         continue;
%     else   
%         movieName = subFn(1:end-10);
%         oriName    = fullfile(path,subFn);    
%         newMatName = fullfile(path2,subFn);
%         movefile(oriName,newMatName);
% %         fullfile(path,subFn)
% %         delete(fullfile(path,subFn))
%     end
% 
% end




% 
% movieName = subFn(1:end-19);
% oriName    = fullfile(path,subFn);  
% 
% newName = [movieName '_' 'DWSiam.mat'];
% newMatName = fullfile(path,newName);




% subFn = files(i).name;
% newFn = [upper(subFn(1)) subFn(2:end)];
% oriName    = fullfile(path,subFn);  
% newFileName = fullfile(path,newFn);  
% movefile(oriName,newFileName);
% 

