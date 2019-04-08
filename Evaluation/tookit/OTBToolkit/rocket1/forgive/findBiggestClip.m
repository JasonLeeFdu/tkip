path = '/home/winston/workSpace/PycharmProjects/tracking/TrackingGuidedInterpolation/Datasets/Original/OTB100';

clips = dir(path);
clips = clips(3:end);
maxLen = -1;
clipName = '';
pos = -3
for i = 1 : length(clips)

    if i == 38
       continue 
    end
    
    clipDir = fullfile(path,clips(i).name,'img');
    thisLen = length(dir(clipDir))-2;
    if thisLen > maxLen
       maxLen =  thisLen;
       clipName = clips(i).name;
       pos = i;
    end
    
    
    
end
clipName
pos













































































































