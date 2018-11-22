% get the imgset & rect
path = '/home/winston/Datasets/Tracking/Original/OTB50/Basketball/img';
gtPath = '/home/winston/Datasets/Tracking/Original/OTB50/Basketball/groundtruth_rect.txt';
files = dir(path);
imgSet = {};
for i =3:length(files)
    imgSet{end+1} = fullfile(path,files(i).name);    
end

rect_anno  = dlmread(gtPath);
init_rect  = rect_anno(1,:); 

clear path
clear gtPath
clear rect_anno
clear files
clear i