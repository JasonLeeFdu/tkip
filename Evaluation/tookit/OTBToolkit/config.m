function conf = config
%CONFIG Summary of this function goes here
%   Detailed explanation goes here
conf = struct;
z = mfilename('fullpath') ;
index_dir=findstr(z,'/');
str_temp = z(1:index_dir(end-3));



%%% configuration of the paths
conf.BASE_PATH = str_temp;
OTBToolkitPath = '/home/winston/workSpace/PycharmProjects/tracking/TrackingGuidedInterpolation/Evaluation/mat/OTBToolkit/';
OTB50Ideal2Path = '/home/winston/Datasets/Tracking/Ideal2/OTB50/';
OTB50OriginalPath = '/home/winston/Datasets/Tracking/Original/OTB50/';
OTB50Std2Path     = '/home/winston/Datasets/Tracking/Std2/OTB50/';
OTB50StdInterp2Path = '/home/winston/Datasets/Tracking/StdInterp2/OTB50/';
OTB50OriginalInterp2Path = '/home/winston/Datasets/Tracking/OriginalInterp2/OTB50/';
OTB100OriginalPath = '/home/winston/Datasets/Tracking/Original/OTB100/';


conf.DatasetPath = containers.Map();
conf.DatasetPath('Ideal2_OTB50') = OTB50Ideal2Path;
conf.DatasetPath('Original_OTB50') = OTB50OriginalPath;
conf.DatasetPath('Std2_OTB50') = OTB50Std2Path;
conf.DatasetPath('StdInterp2_OTB50') = OTB50StdInterp2Path;
conf.DatasetPath('OTBToolkitPath') = OTBToolkitPath;
conf.DatasetPath('OriginalInterp2_OTB50') = OTB50OriginalInterp2Path;
conf.DatasetPath('Original_OTB100') = OTB100OriginalPath;


% configure the results paths
conf.ResType = {'trackingResults','perfMats','figs'};
conf.DownSampleType = {'Ideal2','Std2','StdInterp2','Original','OriginalInterp2'};
conf.DBType = {'OTB50','OTB100','TempleColor128','VOT2016'};
conf.RES_MIDDLE_PART = 'Evaluation/results/';


%% for specific video startFrame and endFrame config
conf.weirdVideoList = {'David','Football1','Freeman3','Freeman4','Diving','Tiger1'};
conf.OriginalStartEndF = containers.Map();
conf.OriginalStartEndF('David')       = [300,770];
conf.OriginalStartEndF('Football1')   = [1,74];
conf.OriginalStartEndF('Freeman3')    = [1,460];
conf.OriginalStartEndF('Freeman4')    = [1,283];
conf.OriginalStartEndF('Diving')      = [1,215];
conf.OriginalStartEndF('Tiger1')      = [6,354];

conf.IdealStartEndF = containers.Map();                  % manually anno
conf.IdealStartEndF('David_2')        = [301,769];        % 1 1
conf.IdealStartEndF('Football1_2')    = [1,73];           % 0 1
conf.IdealStartEndF('Freeman3_2')     = [1,459];          % 0 1
conf.IdealStartEndF('Freeman4_2')     = [1,283];          % 0 0
conf.IdealStartEndF('Diving_2')       = [1,215];          % 0 0
conf.IdealStartEndF('Tiger1_2')      = [7,353];
conf.StdInterpStartEndF = conf.IdealStartEndF;
conf.StdStartEndF = containers.Map();       

conf.RateNotInterp = 30;
conf.MotionSearchR = 1.5;
conf.LocalMotionTh = 20.5;




for idxKey = 1:length(keys(conf.IdealStartEndF))
    keyset = keys(conf.IdealStartEndF);
    key = keyset{idxKey};
    dsRate = str2num(key(end));
    tmp = conf.IdealStartEndF(key);
    conf.StdStartEndF(key) = [(tmp(1)-1)/dsRate + 1, (tmp(2)-1)/dsRate + 1];
end

conf.OriginalInterpStartEndF = containers.Map();       
for idxKey = 1:length(keys(conf.OriginalStartEndF))
    keyset = keys(conf.IdealStartEndF);
    key = keyset{idxKey};
    dsRate = str2num(key(end));
    key = key(1:end-2);
    tmp = conf.OriginalStartEndF(key);
    conf.OriginalInterpStartEndF(key) = [(tmp(1)-1)*dsRate + 1, (tmp(2)-1)*dsRate + 1];
end

end

