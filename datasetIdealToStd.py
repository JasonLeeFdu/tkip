import matplotlib.pyplot as plt
from scipy.misc import imresize
import torch.optim as optim
from torch.autograd import Variable
import os
import numpy as np
import config as conf
import scipy.io as sio
import tools.commons as comm
import shutil

### 设11111置

srcDownSampleType = 'Ideal'                                          # 'Original' 'Ideal','DS2','DSInterp2'  *‘StdInterpMutual’
dstDownSampleType = 'Std'                                          # 'Original' 'Ideal','DS2','DSInterp2'  *‘StdInterpMutual’
dBType = 'OTB50'                                                        # 'OTB50','OTB100','TempleColor128','VOT2016'
dsRate = 2


if srcDownSampleType == 'Original':
    scrDatasetName = '{}_{}'.format(srcDownSampleType, dBType)
else:
    scrDatasetName = '{}{}_{}'.format(srcDownSampleType,dsRate,dBType)

if dstDownSampleType == 'Original':
    dstDatasetName = '{}_{}'.format(dstDownSampleType, dBType)
else:
    dstDatasetName = '{}{}_{}'.format(dstDownSampleType,dsRate,dBType)


scrDatasetBasePath = conf.DatasetPath[scrDatasetName]
dstDatasetBasePath = conf.DatasetPath[dstDatasetName]

videoList = os.listdir(scrDatasetBasePath)
videoList.sort()

if not os.path.exists(dstDatasetBasePath):
    shutil.copytree(scrDatasetBasePath,dstDatasetBasePath)
else:
    shutil.rmtree(dstDatasetBasePath)
    shutil.copytree(scrDatasetBasePath, dstDatasetBasePath)

videoCounter = 0
for video in videoList:
    videoCounter += 1
    print('===========================' + '第' + str(videoCounter) + '个视频，共' + str(
        len(videoList)) + '个视频' + '====================================')
    ## read video info and gt anno
    imgSetPath = os.path.join(dstDatasetBasePath,video,'img')
    imgSet = os.listdir(imgSetPath)
    imgSet = [f for f in imgSet if f.endswith(".jpg")]
    imgSet.sort()
    ## 后面仅仅对imgSet降维
    assignIdx = 1
    for i in range(len(imgSet)):
        if i % dsRate == 0:     # 关键帧，保留
            oldName = os.path.join(dstDatasetBasePath,video,'img',imgSet[i])
            fn = '%04d.jpg' % assignIdx
            assignIdx += 1
            newName = os.path.join(dstDatasetBasePath,video,'img',fn)
            if oldName != newName:
                os.rename(oldName,newName)
        else:                   # 非关键帧，需要删除
            oldName = os.path.join(dstDatasetBasePath, video, 'img', imgSet[i])
            os.remove(oldName)





'''



for video in videoList:
    dstVideoDir = os.path.join(dstDatasetBasePath,video)
    if not os.path.exists(dstVideoDir):
        os.mkdir(dstVideoDir)
        os.mkdir(os.path.join(dstVideoDir,'img'))
'''


### 文件结构：





## 如果没有，新建
## 确定新的开始与结束号码
## 不采样，拷贝开始结束之间的图片
## 修改gt




