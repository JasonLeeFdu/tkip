import os
import numpy

import tools.makeVideo as mk
import config as conf
import shutil




dsTypeFrom = 'OriginalInterp'                                                                                   ######set manually 
dsRate     = 2                                                                                                  ######set manually
dbType     = 'OTB50'                                                                                            ######set manually
path = '/home/winston/OTB50_result/'                                                                            ######set manually
labelDsTypeFrom = 'Original'                                                                                    ######set manually

  


if __name__ == "__main__":
    targetPath = os.path.join(conf.BASE_PATH,'Datasets',dsTypeFrom+str(dsRate))
    if not os.path.exists(targetPath):
        os.mkdir(targetPath)
    fileList = os.listdir(path)
    for filename in fileList:
        print(filename)
        if (filename[-4:] != '.avi') & (filename[-4:] != '.mp4'):
            continue
        if not os.path.exists(os.path.join(targetPath,dbType)):
            os.mkdir(os.path.join(targetPath,dbType))
        tv = os.path.join(targetPath,dbType,filename[:-4]) # put gt.txt
        if not os.path.exists(tv):
            os.mkdir(tv)
            if not os.path.exists(os.path.join(tv,'img')):
                os.mkdir(os.path.join(tv,'img'))
        fileVideoPath = path + filename
        mk.splitVideoIntoImages(fileVideoPath, os.path.join(tv,'img'))
        oldname = os.path.join(conf.DatasetPath[labelDsTypeFrom + str(dsRate) + '_' + dbType], filename[:-4],
                           'groundtruth_rect.txt')
        newname = os.path.join(tv,'groundtruth_rect.txt')
        shutil.copyfile(oldname,newname )

    print('转换完毕')

