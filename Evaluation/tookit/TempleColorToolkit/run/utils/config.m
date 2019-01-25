function conf = config
%CONFIG Summary of this function goes here
%   Detailed explanation goes here
conf = struct;
z = mfilename('fullpath') ;
index_dir=findstr(z,'/');
str_temp = z(1:index_dir(end-2));



%%% configuration of the paths
conf.BASE_PATH = str_temp;


% configure the results paths
conf.ResType = {'trackingResults','perfMats','figs'};
conf.DownSampleType = {'Ideal2','Std2','StdInterp2','Original','OriginalInterp2'};
conf.DBType = {'OTB50','OTB100','TempleColor128','VOT2016'};
conf.RES_MIDDLE_PART = 'results';


%% for specific video startFrame and endFrame config
conf.weirdVideoList = {'David','Football1'};
conf.OriginalStartEndF = containers.Map();
% 因为这两个视频没有从第一帧开始
%conf.OriginalStartEndF('Busstation_ce2')        = [6,400];
conf.OriginalStartEndF('David')                 = [300,770];
conf.OriginalStartEndF('Football1')             = [1,74];
%conf.OriginalStartEndF('Hurdle_ce2')            = [27,330];



conf.RateNotInterp = 30;
conf.MotionSearchR = 1.5;
conf.LocalMotionTh = 20.5;



% 
% for idxKey = 1:length(keys(conf.IdealStartEndF))
%     keyset = keys(conf.IdealStartEndF);
%     key = keyset{idxKey};
%     dsRate = str2num(key(end));
%     tmp = conf.IdealStartEndF(key);
%     conf.StdStartEndF(key) = [(tmp(1)-1)/dsRate + 1, (tmp(2)-1)/dsRate + 1];
% end
% 
% conf.OriginalInterpStartEndF = containers.Map();       
% for idxKey = 1:length(keys(conf.OriginalStartEndF))
%     keyset = keys(conf.IdealStartEndF);
%     key = keyset{idxKey};
%     dsRate = str2num(key(end));
%     key = key(1:end-2);
%     tmp = conf.OriginalStartEndF(key);
%     conf.OriginalInterpStartEndF(key) = [(tmp(1)-1)*dsRate + 1, (tmp(2)-1)*dsRate + 1];
% end

end

