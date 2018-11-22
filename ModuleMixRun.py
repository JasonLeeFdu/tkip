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

import MODULE_DaSiamRPN as filedasiamrpn
import MODULE_ACT as fileact
import MODULE_SIAMFC as filesiamfc


def IOU(rect1, rect2) :
    leftA = rect1[0]
    bottomA = rect1[1]
    rightA = leftA + rect1[2] - 1
    topA = bottomA + rect1[3] - 1
    leftB = rect2[0]
    bottomB = rect2[1]
    rightB = leftB + rect2[2] - 1
    topB = bottomB + rect2[3] - 1
    tmp = (max(0, min(rightA, rightB) - max(leftA, leftB) + 1))* (max(0, min(topA, topB) - max(bottomA, bottomB) + 1))
    areaA = rect1[2]*rect1[3]
    areaB = rect2[2]*rect2[3]
    overlap = tmp / (areaA + areaB - tmp)
    return overlap


def strayedMetric(thisRect, lastRect, method):
    if method == 'IOU':
        res = 0 - IOU(thisRect, lastRect)
    return res

def  combinationStrategy(OriThis, OriItpHThis, CombineLast):
    #% % % % % % % config
    strategyIdx = 1
    if strategyIdx == 1:
        if strayedMetric(OriThis, CombineLast, 'IOU') < strayedMetric(OriItpHThis, CombineLast, 'IOU'):
            #% Ori is better
            newCombination = OriThis
        else:
            #% OriItpH is better
            newCombination = OriItpHThis

    return  newCombination



def ModuleMixRun(moduleName, imgSetOri, imgSetOriItp, init_rect):
    # module configuration
    MD_Ori = None
    MD_OriItp = None
    nFrames = len(imgSetOri)
    retRes = np.zeros([nFrames, 4])
    retRes[1, :] = init_rect
    fps = 0
    Combine_OOIt = init_rect
    choice = ''

    if moduleName.lower() == 'act':
        MD_Ori = fileact.MODULE_ACT()
        MD_OriItp = fileact.MODULE_ACT()
    elif moduleName.lower() == 'siamfc':
        MD_Ori = filesiamfc.MODULE_SiamFC()
        MD_OriItp = filesiamfc.MODULE_SiamFC()
    elif moduleName.lower() == 'dasiamfc':
        MD_Ori = filedasiamrpn.MODULE_DaSiamRPN()
        MD_OriItp = filedasiamrpn.MODULE_DaSiamRPN()
    # core algorithms
    s = time.time()
    MD_Ori.modualInit(imgSetOri[0], init_rect)
    MD_OriItp.modualInit(imgSetOriItp[0], init_rect)

    for t in range(1, nFrames):
        Res_O_t = MD_Ori.modualRun(imgSetOri[t], Combine_OOIt)
        Res_OI_t_05 = MD_OriItp.modualRun(imgSetOriItp[2 * t - 2], Combine_OOIt)
        Res_OI_t = MD_OriItp.modualRun(imgSetOriItp[2 * t - 1], Res_OI_t_05)
        # compare it with Combine_OOIt and get new Combine_OOIt to be the res of
        # time t
        Combine_OOIt = combinationStrategy(Res_O_t, Res_OI_t, Combine_OOIt)
        retRes[t, :] = Combine_OOIt;
        if strayedMetric(Res_O_t, Combine_OOIt, 'IOU') < strayedMetric(Res_OI_t, Combine_OOIt, 'IOU'):
            choice = choice + 'O'
        else:
            choice = choice + 'O'
        if t % 1 == 0:
            print('')
            print('------------------------------{}------------------------------'.format(np.floor(t)))
    e = time.time()
    fps = (nFrames - 1) / (e - s)
    print('')
    return retRes,fps,choice
