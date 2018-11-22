import cv2 as cv
import numpy as np
import scipy.io as sio
import os
import config as cf
import sys

sys.path.append(os.path.dirname(os.path.abspath(__file__)))

import general


##########################
## configuration
FPS = 25
STANDARD_SIZE = (600,400)
PRINT_INTERVAL = 300
##########################
## temporary
##########################


def formvideoFromFolder(srcDir,tgtDir,fileName,fps=FPS, standardOutSize=False, frNumShown=True):
    # correction of the directory
    if srcDir[-1] is not '/':
        srcDir = srcDir + '/'
    if tgtDir[-1] is not '/':
        tgtDir = tgtDir + '/'
    # read the jpg list
    fileList = os.listdir(srcDir)
    fileList.sort()
    # get the size of the image
    imw = 0
    imh = 0
    for fn in fileList:
        if fn[-4:] == '.jpg':
            im = cv.imread(srcDir+fn)
            imw += im.shape[1]
            imh += im.shape[0]
            break
    fourcc = cv.VideoWriter_fourcc('M', 'J', 'P', 'G')
    if standardOutSize:
        imw = STANDARD_SIZE[0]
        imh = STANDARD_SIZE[1]
    videoWriter = cv.VideoWriter(tgtDir+fileName, fourcc, fps, (imw,imh))
    counter = 0
    for fn in fileList:
        if fn[-4:] != '.jpg':
            continue
        im = cv.imread(srcDir+fn)
        if standardOutSize:
            im = cv.resize(im,(imw,imh))
        # write frame number
        if frNumShown:
            im = cv.putText(im, '#'+str(counter), (0, round(imh * 0.12)), cv.FONT_HERSHEY_SIMPLEX, imw*2.0/625, (0, 255, 255), round(imw/260))
        videoWriter.write(im)
        counter += 1
        if counter %PRINT_INTERVAL == 0:
            print('Making Video by Frames. Processed:' + str(100.0 * counter / len(fileList)) + '%')
    videoWriter.release()
    print('Making Video by Frames. Finished!')


def readTrackingGTOTB(filePath):
    # tracking shape (#TIME,4)
    fopen = open(filePath, 'r')
    lines = fopen.readlines()
    timeInterval = len(lines)
    resMtrx = np.zeros([timeInterval,4],dtype=np.int32)
    for index, value in enumerate(lines):
        if lines[index][-1:]=='\n':
            lines[index] = lines[index][:-1]
        if lines[index].find(',') != -1:
            lineTemp = lines[index].split(',')
        elif lines[index].find('\t') != -1:
            lineTemp = lines[index].split('\t')
        for index1, value1 in enumerate(lineTemp):
            resMtrx[index][index1] = int(lineTemp[index1])
    return resMtrx


def drawRectOnVideo(videoMeta,rectMtrx,dstDir,fps = FPS,metaType='videoCapture',frNumShown=True):
    # by default, videoMeta is video
    if metaType == 'videoCapture':
        cap = videoMeta
        cap = cv.VideoCapture(videoMeta)
        imw = int(cap.get(cv.CAP_PROP_FRAME_WIDTH))
        imh = int(cap.get(cv.CAP_PROP_FRAME_HEIGHT))
        nFrames = int(cap.get(cv.CAP_PROP_FRAME_COUNT))
        if nFrames != rectMtrx.shape[0]:
            exit(-3)
        fourcc = cv.VideoWriter_fourcc('M', 'J', 'P', 'G')
        writer = cv.VideoWriter(dstDir, fourcc, fps, (imw, imh))
        lineWidth = max(1,round(imw/300))
        counter = 0
        while True:
            success, frame = cap.read()
            if not success: break
            frame = cv.rectangle(img=frame,pt1=(rectMtrx[counter][0],rectMtrx[counter][1]),pt2=(rectMtrx[counter][0]+rectMtrx[counter][2],rectMtrx[counter][1]+rectMtrx[counter][3]),color=(255,0,245),thickness=lineWidth)
            if frNumShown:
                frame = cv.putText(frame, '#' + str(counter), (0, round(imh * 0.12)), cv.FONT_HERSHEY_SIMPLEX,
                                imw * 2.0 / 625, (0, 255, 255), round(imw / 260))
            writer.write(frame)
            counter += 1
            if counter%PRINT_INTERVAL == 0:
                print('Drawing rect on the video. Processed:' + str(100.0 * counter / nFrames) + '%')
        cap.release()
        writer.release()
        print('Drawing rect on the video complete!')

    elif metaType == 'videoPath':
        cap = cv.VideoCapture(videoMeta)
        imw = int(cap.get(cv.CAP_PROP_FRAME_WIDTH))
        imh = int(cap.get(cv.CAP_PROP_FRAME_HEIGHT))
        nFrames = int(cap.get(cv.CAP_PROP_FRAME_COUNT))
        if nFrames != rectMtrx.shape[0]:
            exit(-3)
        fourcc = cv.VideoWriter_fourcc('M', 'J', 'P', 'G')
        writer = cv.VideoWriter(dstDir, fourcc, fps, (imw, imh))
        lineWidth = max(1,round(imw/300))
        counter = 0
        while True:
            success, frame = cap.read()
            if not success: break
            frame = cv.rectangle(img=frame,pt1=(rectMtrx[counter][0],rectMtrx[counter][1]),pt2=(rectMtrx[counter][0]+rectMtrx[counter][2],rectMtrx[counter][1]+rectMtrx[counter][3]),color=(255,0,245),thickness=lineWidth)
            if frNumShown:
                frame = cv.putText(frame, '#' + str(counter), (0, round(imh * 0.12)), cv.FONT_HERSHEY_SIMPLEX,
                                imw * 2.0 / 625, (0, 255, 255), round(imw / 260))
            writer.write(frame)
            counter += 1
            if counter%PRINT_INTERVAL == 0:
                print('Drawing rect on the video. Processed:' + str(100.0 * counter / nFrames) + '%')
        cap.release()
        writer.release()
        print('Drawing rect on the video complete!')

    elif metaType == 'imagePath':
        imw = 0
        imh = 0
        nFrames = 0
        rawfileList = os.listdir(videoMeta)
        fileList = list()
        for fn in rawfileList:
            if fn[-4:] == '.jpg':
                im = cv.imread(videoMeta + fn)
                imw += im.shape[1]
                imh += im.shape[0]
                break
        for fn in rawfileList:
            if fn[-4:] == '.jpg':
                fileList.append(fn)
                nFrames += 1
        fileList.sort()
        fourcc = cv.VideoWriter_fourcc('M', 'J', 'P', 'G')
        writer = cv.VideoWriter(dstDir, fourcc, fps, (imw, imh))
        lineWidth = max(1,round(imw/300))
        counter = 0
        for frameName in fileList:
            frame = cv.imread(videoMeta+frameName)
            frame = cv.rectangle(img=frame,pt1=(rectMtrx[counter][0],rectMtrx[counter][1]),pt2=(rectMtrx[counter][0]+rectMtrx[counter][2],rectMtrx[counter][1]+rectMtrx[counter][3]),color=(255,0,245),thickness=lineWidth)
            if frNumShown:
                frame = cv.putText(frame, '#' + str(counter), (0, round(imh * 0.12)), cv.FONT_HERSHEY_SIMPLEX,
                                imw * 2.0 / 625, (0, 255, 255), round(imw / 260))
            writer.write(frame)
            counter += 1
            if counter%PRINT_INTERVAL == 0:
                print('Drawing rect on the video. Processed:' + str(100.0 * counter / nFrames) + '%')
        writer.release()
        print('Drawing rect on the video complete!')


def splitVideoIntoImages(videoMeta,dstDir):
    if isinstance(videoMeta,cv.VideoCapture):
        cap = videoMeta
    elif isinstance(videoMeta,str):
        cap = cv.VideoCapture(videoMeta)
    nFrames = int(cap.get(cv.CAP_PROP_FRAME_COUNT))
    counter = 1
    while True:
        success, frame = cap.read()
        if not success: break
        if int(counter / 1000)!=0:      # 4-digit
            fileName = str(counter)+'.jpg'
        elif int(counter / 100)!=0:     # 3-digit
            fileName = '0'+ str(counter)+'.jpg'
        elif int(counter / 10)!=0:      # 2-digit
            fileName = '00' + str(counter) + '.jpg'
        else:
            fileName = '000' + str(counter) + '.jpg'
        cv.imwrite(os.path.join(dstDir,fileName),frame)
        counter +=1
        if counter%PRINT_INTERVAL==0:
            print('Splitting the video. Processed:' + str(100.0 * counter / nFrames) + '%')
    print('Splitting the video finished!')

def main():
    path = '/home/winston/Interpolated/'
    fileList = os.listdir(path)
    for filename in fileList:
        if (filename[-4:] != '.avi') & (filename[-4:] != '.mp4'):
            continue
        fileVideoPath = path + filename
        fileDirPath = fileVideoPath[:-4]+'/'
        if not os.path.exists(fileDirPath):
            os.mkdir(fileDirPath)
        splitVideoIntoImages(fileVideoPath,fileDirPath)
    print('转换完毕')



if __name__=="__main__":
    main()










'''

data = sio.loadmat('train_data.mat');
data = data['data']

'''