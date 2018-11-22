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

import tools.commons as comm




if __name__ == "__main__":
    dataset_folder = '/home/winston/workSpace/PycharmProjects/tracking/TrackingGuidedInterpolation/Datasets/Original/OTB100/'
    videos_list = [v for v in os.listdir(dataset_folder)]
    videos_list.sort();
    gt, img_list, _, _ = comm.init_video(dataset_folder, 'Jogging_1')

    for trkName in conf.trackers.keys():
        print('Name: ', trkName)
        result_bb, fps = conf.trackers[trkName].go(img_list, gt[0])

        print('res bb: ', str(result_bb))
        print('fps: ',str(fps))












