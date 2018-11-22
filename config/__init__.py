import sys
import time
import argparse
import matplotlib.pyplot as plt
from scipy.misc import imresize
import torch.optim as optim
from torch.autograd import Variable
import os
import numpy as np

### configuration of the trackers
baseACTPath = os.path.dirname(__file__)
baseACTPath = baseACTPath[:-6]
sys.path.insert(0,baseACTPath + 'baselines/ACT')
sys.path.insert(0,baseACTPath + 'baselines/SiamFC')
sys.path.insert(0,baseACTPath + 'baselines/DaSiamRPN')
import interfaceACT as trkACT
import interfaceSiamFC as trkSiamFC
import interfaceDaSiamRPN as trkDaSiamRPN
import MODULE_ACT as modAct
import MODULE_DaSiamRPN as modDaSiamRPN
import MODULE_DaSiamRPN as modDaSiamRPN


trackers = dict()
trackers['SiamFC'] = trkSiamFC
trackers['ACT'] = trkACT
trackers['DaSiamRPN'] = trkDaSiamRPN



### configuration of the paths
HELP_BUILD_PATH = True
BASE_PATH = os.path.abspath(os.path.dirname(__file__)+os.path.sep+"..")

__OTBToolkitPath = '/home/winston/workSpace/PycharmProjects/tracking/TrackingGuidedInterpolation/Evaluation/mat/OTBToolkit/'
__OTB50Ideal2Path = '/home/winston/Datasets/Tracking/Ideal2/OTB50/'
__OTB50OriginalPath = '/home/winston/Datasets/Tracking/Original/OTB50/'
__OTB50Std2Path     = '/home/winston/Datasets/Tracking/Std2/OTB50/'
__OTB50StdInterp2Path = '/home/winston/Datasets/Tracking/StdInterp2/OTB50/'
__OTB50OriginalInterp2Path = '/home/winston/Datasets/Tracking/OriginalInterp2/OTB50/'


DatasetPath = dict()
DatasetPath['Ideal2_OTB50'] = __OTB50Ideal2Path
DatasetPath['Original_OTB50'] = __OTB50OriginalPath
DatasetPath['Std2_OTB50'] = __OTB50Std2Path
DatasetPath['StdInterp2_OTB50'] = __OTB50StdInterp2Path
DatasetPath['OriginalInterp2_OTB50'] = __OTB50OriginalInterp2Path;


# configure the results paths
ResType = ['trackingResults','perfMats','figs']
DownSampleType = ['Ideal2','Std2','StdInterp2','Original','OriginalInterp2']
DBType = ['OTB50','OTB100','TempleColor128','VOT2016']
RES_MIDDLE_PART = 'Evaluation/results'

if HELP_BUILD_PATH:
    for rtelem in ResType:
        a = os.path.join(BASE_PATH,RES_MIDDLE_PART,rtelem)
        if not os.path.exists(os.path.join(BASE_PATH,RES_MIDDLE_PART,rtelem)):
            os.mkdir(os.path.join(BASE_PATH,RES_MIDDLE_PART,rtelem))
        for dselem in DownSampleType:
            b = os.path.join(BASE_PATH, RES_MIDDLE_PART, rtelem,dselem)
            if not os.path.exists(os.path.join(BASE_PATH, RES_MIDDLE_PART, rtelem,dselem)):
                os.mkdir(os.path.join(BASE_PATH, RES_MIDDLE_PART, rtelem,dselem))
            for dbelem in DBType:
                c = os.path.join(BASE_PATH, RES_MIDDLE_PART, rtelem, dselem, dbelem)
                if not os.path.exists(os.path.join(BASE_PATH, RES_MIDDLE_PART, rtelem, dselem, dbelem)):
                    os.mkdir(os.path.join(BASE_PATH, RES_MIDDLE_PART, rtelem, dselem, dbelem))


## for specific video startFrame and endFrame config
weirdVideoList = ['David','Football1','Freeman3','Freeman4','Diving']
OriginalStartEndF = dict()
OriginalStartEndF['David']       = [300,770]
OriginalStartEndF['Football1']   = [1,74]
OriginalStartEndF['Freeman3']    = [1,460]
OriginalStartEndF['Freeman4']    = [1,283]
OriginalStartEndF['Diving']      = [1,215]


IdealStartEndF = dict() # manually
IdealStartEndF['David_2']        = [301,769]        # 1 1
IdealStartEndF['Football1_2']    = [1,73]           # 0 1
IdealStartEndF['Freeman3_2']     = [1,459]          # 0 1
IdealStartEndF['Freeman4_2']     = [1,283]          # 0 0
IdealStartEndF['Diving_2']       = [1,215]          # 0 0

StdInterpStartEndF = IdealStartEndF.copy()

StdStartEndF = dict()
for key in IdealStartEndF.keys():
    dsRate = int(key[-1])
    StdStartEndF[key] = [-1,-1]
    StdStartEndF[key][0] = (IdealStartEndF[key][0]-1)/dsRate + 1
    StdStartEndF[key][1] = (IdealStartEndF[key][1]-1)/dsRate + 1
