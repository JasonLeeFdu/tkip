import sys
import time
import argparse
import matplotlib.pyplot as plt
from scipy.misc import imresize
import torch.optim as optim
from torch.autograd import Variable
import os
import numpy as np
import config as conf
import scipy.io as sio
import tools.commons as comm
import ModuleMixRun as mmr

#########设置
##

resType = 'trackingResults'                                         # 'trackingResults','perfMats','figs'
evalType = 'OPE'                                                    # 'OPE' None 只有OPE
downSampleType = 'Original_And_OriginalInterp'                                   # 'Original' 'Ideal','DS2','DSInterp2'  'OriginalInterp'  *‘StdInterpMutual’
dBType = 'OTB50'                                                    # 'OTB50','OTB100','TempleColor128','VOT2016'
dsRate = 2

basePath = conf.BASE_PATH
middlePart = conf.RES_MIDDLE_PART
resMatFileNameModel = '{}_{}.mat'
datasetNameOri = '{}_{}'.format('Original', dBType)
datasetNameOriItp = '{}{}_{}'.format('OriginalInterp',dsRate,dBType)

downSampleTypeNRate = downSampleType + str(dsRate)

'''
ResType = ['trackingResults','perfMats','figs']
DownSampleType = ['Ideal','DS2','DS2Interp']
DBType = ['OTB50','OTB100','TempleColor128','VOT2016']
'''
resFileName = os.path.join(basePath,middlePart,resType,downSampleTypeNRate,dBType,resMatFileNameModel)



# 获取数据集种类、数据集测试项目
datasetBasePath = conf.DatasetPath[datasetNameOri]
datasetBaseOriItpPath = conf.DatasetPath[datasetNameOriItp]

videoList = os.listdir(datasetBasePath)
videoList.sort()
videoListOI = os.listdir(datasetBaseOriItpPath)
videoListOI.sort()
trkList = list(conf.trackers.keys())
trkList.sort()
videoCounter = 0

for videoName in videoList:
    ###@@@
#    if videoName not in conf.weirdVideoList
#        continue

    videoCounter += 1
    print('==========================='+'第'+str(videoCounter) +'个视频，共'+str(len(videoList))+'个视频' +'====================================')
    trkCounter = 0
    gt, img_list, startFrame, endFrame = comm.init_video(datasetBasePath, videoName,'Original')
    img_list_OriItp = [os.path.join(datasetBaseOriItpPath,videoName,'img',f) for f in os.listdir(   os.path.join(datasetBaseOriItpPath,videoListOI[videoCounter-1],'img')) if f.endswith(".jpg")]
    img_list_OriItp.sort()
    startFrameOI = 1 + (startFrame-1) * dsRate
    endFrameOI = 1 + (endFrame-1) * dsRate
    img_list_OriItp = img_list_OriItp[startFrameOI-1:endFrameOI+1-1]
    for trkName in trkList:
        trkCounter += 1
        saveName = resFileName.format(videoName,trkName)
        ###@@@
        if os.path.exists(saveName):
            print('已经存在:', saveName)
            continue
        resList = np.zeros((1, 1), dtype=np.object)

        result_bb, fps = mmr.ModuleMixRun(trkName,img_list, img_list_OriItp, gt[0])


        # 将结果与GT对齐，此时如果是ideal，则需要对结果进行降维!!此时如果有需要可以降维
        resDict = dict()
        resDict['fps']              = fps
        resDict['type']             = 'rect'
        resDict['len']              = endFrame - startFrame + 1
        resDict['startFrame']       = startFrame
        resDict['endFrame']         = endFrame
        resDict['anno']             = gt
        resDict['typeName']         = downSampleType
        resDict['dsRate']           = 1
        newEnd = endFrame - startFrame
        idxChoice = range(0, newEnd+1, dsRate)

        # result down-sampling
        if downSampleType.find('Ideal')!=-1 :
            result_bb = result_bb[idxChoice,:]
            resDict['res']    = result_bb
            resDict['dsRate'] = dsRate
        elif downSampleType.find('StdInterp')!=-1:
            result_bb = result_bb[idxChoice, :]
            resDict['res']    = result_bb
            resDict['dsRate'] = dsRate
        else:
            resDict['res'] = result_bb

        resList[0,0] = resDict
        print('{}--{}，完毕({}/{}),({}/{}),fps: {}'.format(videoName,trkName,str(len(videoList)),str(videoCounter),str(len(conf.trackers.keys())),str(trkCounter),str(fps)))
        sio.savemat(saveName, {'results': resList})














