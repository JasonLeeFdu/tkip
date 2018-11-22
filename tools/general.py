import numpy as np


def conerToCenter(x1,y1,x2,y2):
    cx = (x1 + x2)/2
    cy = (y1 + y2)/2
    width = x2 - x1
    height = y2 - y1
    return cx,cy,width,height
def centerToConer(cx,cy,width,height):
    x1 = cx - width / 2
    y1 = cy - height / 2
    x2 = cx + width / 2
    y2 = cy + height / 2
    return x1,y1,x2,y2
