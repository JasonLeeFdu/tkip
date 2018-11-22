import sys
import time
import argparse
import matplotlib.pyplot as plt
from scipy.misc import imresize
import torch.optim as optim
from torch.autograd import Variable
import os
import PIL.Image as Image
import numpy as np

import config as conf


class Sequence:
    def printContent(self):
        print('name: ',end="")
        print(self.name)
        print('path: ',end="")
        print(self.path)
        print('startFrame: ',end="")
        print(self.startFrame)
        print('endFrame: ',end="")
        print(self.endFrame)
        print('attributes: ',end="")
        print(self.attributes)
        print('nz: ',end="")
        print(self.nz)
        print('ext: ',end="")
        print(self.ext)
        print('lenn: ',end="")
        print(self.lenn)
        print('imgFormat: ',end="")
        print(self.imgFormat)
        print('init_rect: ',end="")
        print(self.init_rect)
        print('anno: ')
        print(self.anno)
        print('s_frames: ')
        print(self.s_frames)
        print('===================================')



    ##传进来的是处理好的，endFrame
    def __init__(self, name, path, startFrame, endFrame, attributes,
        nz, ext, lenn,imgFormat, anno, init_rect, sysType='NORMAL',dsRate = 1):
        self.name = name
        self.path = path
        self.startFrame = startFrame
        self.endFrame = endFrame
        self.attributes = attributes
        self.nz = nz
        self.lenn = lenn
        self.ext = ext
        self.imgFormat = imgFormat
        self.anno = anno
        self.init_rect = init_rect
        self.typeName = sysType
        self.downSampleRate = dsRate

        self.__dict__ = OrderedDict([
            ('name', self.name),
            ('path', self.path),
            ('startFrame', self.startFrame),
            ('endFrame', self.endFrame),
            ('attributes', self.attributes),
            ('nz', self.nz),
            ('ext', self.ext),
            ('lenn', self.lenn),
            ('imgFormat', self.imgFormat),
            ('anno', self.anno),
            ('init_rect', self.init_rect),
            ('typeName', self.typeName),
            ('downSampleRate', self.downSampleRate),
            ('s_frames', self.s_frames)])


def numOld2New(old,ds):
    new = int((old-1)/ds) + 1
    return new

def numNew2Old(new,ds):
    old = ds * (new - 1) + 1
    return old

def numOldLeftSlide(old1,ds):
    old2 = old1 - (old1-1)%ds
    return old2
def numOldRightSlide(old1,ds):
    old2 = (1-old1)%ds + old1
    return old2



def init_video(img_path, videoName, downSampleTypeNRate): #
    ### video specific(start end) and within startframe endframe,
    if 'vot' in img_path:
        video_folder = os.path.join(img_path, videoName)
    else:
        video_folder = os.path.join(img_path, videoName, 'img')
    frame_name_shortlist = [f for f in os.listdir(video_folder) if f.endswith(".jpg")]
    frame_name_list = [os.path.join(video_folder, '') + s for s in frame_name_shortlist]
    frame_name_shortlist.sort()
    frame_name_list.sort()

    ## downSampleRate
    if downSampleTypeNRate[-1].isdigit():
        dsRate = int(downSampleTypeNRate[-1])
    else:
        dsRate = 1

    ##start and end frame
    startFrame = int(frame_name_shortlist[0][:-4])
    endFrame   = int(frame_name_shortlist[-1][:-4])
    if videoName in conf.weirdVideoList:
        if downSampleTypeNRate.find('Original')!= -1:
            startFrame = conf.OriginalStartEndF[videoName][0]
            endFrame   = conf.OriginalStartEndF[videoName][1]
        elif downSampleTypeNRate.find('Ideal')!= -1:
            startFrame = conf.IdealStartEndF[videoName+'_'+str(dsRate)][0]
            endFrame   = conf.IdealStartEndF[videoName+'_'+str(dsRate)][1]
        elif downSampleTypeNRate.find('StdInterp')!= -1:
            startFrame = conf.IdealStartEndF[videoName+'_'+str(dsRate)][0]
            endFrame = conf.IdealStartEndF[videoName+'_'+str(dsRate)][1]
        elif downSampleTypeNRate.find('Std')!= -1:
            startFrame = conf.IdealStartEndF[videoName+'_'+str(dsRate)][0]
            startFrame = numOld2New(startFrame,dsRate)
            endFrame = conf.IdealStartEndF[videoName+'_'+str(dsRate)][1]
            endFrame = numOld2New(endFrame,dsRate)

    ## 截取imgSet list
    frame_name_list = frame_name_list[startFrame-1:endFrame]
    img = Image.open(frame_name_list[0])
    frame_sz = np.asarray(img.size)
    frame_sz[1], frame_sz[0] = frame_sz[0], frame_sz[1]


    # 读取GT，其中GT已按照各种不一样的方式抽样修改完毕
    if 'VOT' in img_path:
        gt_file = os.path.join(video_folder, 'groundtruth.txt')
    else:
        gt_file = os.path.join(os.path.join(img_path, videoName), 'groundtruth_rect.txt')
    gt = np.genfromtxt(gt_file, delimiter=',')
    if gt.shape.__len__() == 1:  # isnan(gt[0])
        gt = np.loadtxt(gt_file)

    # n_frames = len(frame_name_list)
    ## assert n_frames == len(gt),  这个不满足

    #return gt, frame_name_list, frame_sz, n_frames
    return gt, frame_name_list, startFrame, endFrame






def overlap_ratio(rect1, rect2):
    '''
    Compute overlap ratio between two rects
    - rect: 1d array of [x,y,w,h] or
            2d array of N x [x,y,w,h]
    '''

    if rect1.ndim == 1:
        rect1 = rect1[None, :]
    if rect2.ndim == 1:
        rect2 = rect2[None, :]

    left = np.maximum(rect1[:, 0], rect2[:, 0])
    right = np.minimum(rect1[:, 0] + rect1[:, 2], rect2[:, 0] + rect2[:, 2])
    top = np.maximum(rect1[:, 1], rect2[:, 1])
    bottom = np.minimum(rect1[:, 1] + rect1[:, 3], rect2[:, 1] + rect2[:, 3])

    intersect = np.maximum(0, right - left) * np.maximum(0, bottom - top)
    union = rect1[:, 2] * rect1[:, 3] + rect2[:, 2] * rect2[:, 3] - intersect
    iou = np.clip(intersect / union, 0, 1)
    return iou


def crop_image(img, bbox, img_size=107, padding=16, valid=False):
    x, y, w, h = np.array(bbox, dtype='float32')

    half_w, half_h = w / 2, h / 2
    center_x, center_y = x + half_w, y + half_h

    if padding > 0:
        pad_w = padding * w / img_size
        pad_h = padding * h / img_size
        half_w += pad_w
        half_h += pad_h

    img_h, img_w, _ = img.shape
    min_x = int(center_x - half_w + 0.5)
    min_y = int(center_y - half_h + 0.5)
    max_x = int(center_x + half_w + 0.5)
    max_y = int(center_y + half_h + 0.5)

    if valid:
        min_x = max(0, min_x)
        min_y = max(0, min_y)
        max_x = min(img_w, max_x)
        max_y = min(img_h, max_y)

    if min_x >= 0 and min_y >= 0 and max_x <= img_w and max_y <= img_h:
        cropped = img[min_y:max_y, min_x:max_x, :]

    else:
        min_x_val = max(0, min_x)
        min_y_val = max(0, min_y)
        max_x_val = min(img_w, max_x)
        max_y_val = min(img_h, max_y)

        cropped = 128 * np.ones((max_y - min_y, max_x - min_x, 3), dtype='uint8')
        cropped[min_y_val - min_y:max_y_val - min_y, min_x_val - min_x:max_x_val - min_x, :] \
            = img[min_y_val:max_y_val, min_x_val:max_x_val, :]

    scaled = imresize(cropped, (img_size, img_size))
    return scaled




######## temp & useless

def split_seq_TRE(seq, rect_anno,sysType='NORMAL',dsRate = 1):
    minNum = 20
    segNum = minNum

    idx = range(1, seq.lenn + 1)

    idx = [x for x in idx if x > 0]
    for i in reversed(range(len(idx))):
        if seq.lenn - idx[i] + 1 >= minNum:
            endSeg = idx[i]
            endSegIdx = i + 1
            break

    startFrIdxOne = np.floor(np.arange(1, endSegIdx, endSegIdx/(segNum-1)))
    startFrIdxOne = np.append(startFrIdxOne, endSegIdx)
    startFrIdxOne = [int(x) for x in startFrIdxOne]

    subAnno = []
    subSeqs = []

    # 除了s_frames,其他全部正常
    for i in range(len(startFrIdxOne)):
        index = idx[startFrIdxOne[i] - 1] - 1
        subS = copy.deepcopy(seq)
        subS.startFrame = index + seq.startFrame
        subS.lenn = subS.endFrame - subS.startFrame + 1
        subS.annoBegin = seq.startFrame
        subS.init_rect = rect_anno[index]
        anno = rect_anno[index:]
        subS.anno     = seq.anno[index:,:]
        subS.s_frames = seq.s_frames[index:]
        if sysType == 'NORMAL':
            xz = 2
        elif sysType == 'INTERPOLATE':
            newStart = 1 + dsRate *(subS.startFrame-1)
            newEnd = 1 + dsRate * (subS.endFrame - 1)
            subS.s_frames = seq.s_frames[newStart-1:newEnd]
        subSeqs.append(subS)
        subAnno.append(anno)

    return subSeqs, subAnno


def retShiftTypeList():
    res = list()
    res.append('scale_7')
    res.append('scale_8')
    res.append('scale_9')
    res.append('scale_11')
    res.append('scale_12')
    res.append('scale_13')
    res.append('left')
    res.append('right')
    res.append('up')
    res.append('down')
    res.append('topLeft')
    res.append('topRight')
    res.append('bottomLeft')
    res.append('bottomRight')
    res.sort()
    return res



def shift_init_BB(r, shiftType, imgH, imgW):

    center = [r[0]+r[2]/2.0, r[1]+r[3]/2.0]

    br_x = r[0] + r[2] - 1
    br_y = r[1] + r[3] - 1

    if shiftType == 'scale_7':
        ratio = 0.7
        w = ratio * r[2]
        h = ratio * r[3]
        r = map(round, [center[0]-w/2.0, center[1]-h/2.0, w, h])

    elif shiftType == 'scale_8':
        ratio = 0.8
        w = ratio * r[2]
        h = ratio * r[3]
        r = map(round, [center[0]-w/2.0, center[1]-h/2.0, w, h])

    elif shiftType == 'scale_9':
        ratio = 0.9
        w = ratio * r[2]
        h = ratio * r[3]
        r = map(round, [center[0]-w/2.0, center[1]-h/2.0, w, h])

    elif shiftType == 'scale_11':
        ratio = 1.1
        w = ratio * r[2]
        h = ratio * r[3]
        r = map(round, [center[0]-w/2.0, center[1]-h/2.0, w, h])

    elif shiftType == 'scale_12':
        ratio = 1.2
        w = ratio * r[2] # 104.4
        h = ratio * r[3] # 382.8
        r = map(round, [center[0]-w/2.0, center[1]-h/2.0, w, h])

    elif shiftType == 'scale_13':
        ratio = 1.3
        w = ratio * r[2]
        h = ratio * r[3]
        r = map(round, [center[0]-w/2.0, center[1]-h/2.0, w, h])

    elif shiftType == 'left':
        r[0] -= round(0.1 * r[2] + 0.5)

    elif shiftType == 'right':
        r[0] += round(0.1 * r[2] + 0.5)

    elif shiftType == 'up':
        r[1] -= round(0.1 * r[3] + 0.5)

    elif shiftType == 'down':
        r[2] += round(0.1 * r[3] + 0.5)

    elif shiftType == 'topLeft':
        r[0] = round(r[0] - 0.1 * r[2])
        r[1] = round(r[1] - 0.1 * r[3])
        r[2] = br_x - r[0] + 1
        r[3] = br_y - r[1] + 1

    elif shiftType == 'topRight':
        br_x = round(br_x + 0.1 * r[2])
        r[1] = round(r[1] - 0.1 * r[3])
        r[2] = br_x - r[0] + 1
        r[3] = br_y - r[1] + 1

    elif shiftType == 'bottomLeft':
        r[0] = round(r[0] - 0.1 * r[2])
        br_y = round(br_y + 0.1 * r[3])
        r[2] = br_x - r[0] + 1
        r[3] = br_y - r[1] + 1

    elif shiftType == 'bottomRight':
        br_x = round(br_x + 0.1 * r[2])
        br_y = round(br_y + 0.1 * r[3])
        r[2] = br_x - r[0] + 1
        r[3] = br_y - r[1] + 1

    if r[0] < 1:
        r[0] = 1

    if r[1] < 1:
        r[1] = 1

    if r[0] + r[2] - 1 > imgW:
        r[2] = imgW - r[0] + 1

    if r[1] + r[3] - 1 > imgH:
        r[3] = imgH - r[1] + 1

    return r

