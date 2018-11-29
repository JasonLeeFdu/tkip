xlfn = '/home/winston/Desktop/source_selected.xlsx';
tP   = '/home/winston/Desktop/SRDS/Urban100';



[num,txt] = xlsread(xlfn,'Sheet1', 'B2:B101');



outfilename = websave(fullfile(tP,'1.jpg'),txt{1})

% 
% for i = 1:num
%    Download the image. 
%     fprintf('downloading:%s',txt{i});
%     url = txt{i};
%     
% end