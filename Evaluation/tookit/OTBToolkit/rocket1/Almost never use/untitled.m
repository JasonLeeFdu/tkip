base = '/home/winston/workSpace/PycharmProjects/inpainting_T/edge-connect/xiaojiejie/';
img = imread(fullfile(base,'img.png'));
mask = imread(fullfile(base,'mask.png'));
saveFn = 'oriEdgeMasked.png';
imgGray = rgb2gray(img);
cannyEdge = edge(imgGray,'canny',0.17,2);

cannyEdge = 255*uint8(cannyEdge) .* (255-mask);
imwrite(cannyEdge,fullfile(base,saveFn));




