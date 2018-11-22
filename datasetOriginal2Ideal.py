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

### 设置  

srcDownSampleType = 'Original'                                          # 'Original' 'Ideal','DS2','DSInterp2'  *‘StdInterpMutual’
dstDownSampleType = 'Ideal'                                          # 'Original' 'Ideal','DS2','DSInterp2'  *‘StdInterpMutual’
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
    endFrame = int(imgSet[-1][:-4])
    srcAnnon = os.path.join(scrDatasetBasePath, video, 'groundtruth_rect.txt')
    dstAnnon = os.path.join(dstDatasetBasePath, video, 'groundtruth_rect.txt')
    gt = np.genfromtxt(srcAnnon, delimiter=',')  #
    if (gt == gt).all() == False:
        gt = np.genfromtxt(srcAnnon, delimiter='\t')  ##
    if (gt == gt).all() == False:
        gt = np.genfromtxt(srcAnnon, delimiter=' ')  ###

    ## check the whole OTB50 for inconsistant anno and frames
    if gt.shape[0] != endFrame:
        print('**** ',video,', endFrame: ',str(endFrame))

    ### weird OTB50
    if video in conf.weirdVideoList:
        oldStartFrame = conf.OriginalStartEndF[video][0]
        oldEndFrame   = conf.OriginalStartEndF[video][1]
        newStartFrame = conf.IdealStartEndF['{}_{}'.format(video,str(dsRate))][0]
        newEndFrame   = conf.IdealStartEndF['{}_{}'.format(video,str(dsRate))][1]
        deltaStart = newStartFrame - oldStartFrame
        deltaEnd   = newEndFrame - oldEndFrame
        ## 对齐gt
        if gt.shape[0] == (newEndFrame - newStartFrame + 1):
            print('weird frame is all fine')
        else:
            if deltaEnd == 0:
                gt = gt[deltaStart:,:]
            else:
                gt = gt[deltaStart:deltaEnd,:]
        ## 对齐最后帧
        endFrameNew = comm.numOldLeftSlide(endFrame, dsRate)
        if endFrame != endFrameNew:
            for i in range(endFrameNew + 1, endFrame + 1):
                fn = os.path.join(dstDatasetBasePath, video, 'img', '%04d.jpg' % i)
                os.remove(fn)
        ## downsample
        height = gt.shape[0]
        idxChoice = range(0,height,dsRate)
        gt = gt[idxChoice,:]
        gt = np.savetxt(dstAnnon, gt, delimiter=',')
        continue


    ### Ordinary OTB50
    if dBType == 'OTB50' or dBType=='OTB100':
        endFrameNew = comm.numOldLeftSlide(endFrame,dsRate)
    else:                                                       ###$$$
        endFrameNew = endFrame
    if endFrame != endFrameNew:
        print(video +' modifying: [1,{}] => [1,{}]'.format(str(endFrame),str(endFrameNew)))
        for i in range(endFrameNew+1,endFrame+1):
            fn = os.path.join(dstDatasetBasePath,video,'img','%04d.jpg'%i)
            os.remove(fn)
        gt = gt[0:endFrameNew, :]
    else:
        print(video + ' frames are all fine!')
    # downsample gt anyway
    idxChoice = range(0, endFrameNew, dsRate)
    gt = gt[idxChoice, :]
    gt = np.savetxt(dstAnnon, gt, delimiter=',')





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




