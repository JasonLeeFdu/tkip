function [ dest ] = drawRect( src, rect, lineWidth,color ,rectType)
warning('off')
if strcmp(rectType, 'x1y1x2y2')
    x1 = rect(1);y1=rect(2);x2=rect(3);y2=rect(4);
elseif strcmp(rectType, 'x1y1wh')
    x1=rect(1);y1=rect(2);w=rect(3);h=rect(4);
    x2=x1+w-1;y2=y1+h-1;
elseif strcmp(rectType,'cxcywh')
    cx=rect(1);cy=rect(2);w=rect(3);h=rect(4);
    x1=cx-(w-1)/2;y1=cy-(h-1)/2;
    x2=cx+(w-1)/2;y2=cy+(h-1)/2;
end

if size(size(src),2) == 2
    isGray = true;
    dest(:, : ,1) = src;
    dest(:, : ,2) = src;
    dest(:, : ,3) = src;
else
    isGray = false;
    dest = src;
end
W = size(src,2);
H = size(src,1);
% up
sizer= size(dest( max(1,(y1-lineWidth)) : min(H,(y1+lineWidth)), max(1,(x1-lineWidth)) : min(W,(x2+lineWidth)) , :)  );
sizer(3) = 1;
 targetColor = reshape(color,[1,1,3]);
%end
targetColor = repmat(targetColor,sizer);
dest( max(1,(y1-lineWidth)) : min(H,(y1+lineWidth)), max(1,(x1-lineWidth)) : min(W,(x2+lineWidth)) , :) =  targetColor;
%down
sizer= size(dest(   max(1,(y2-lineWidth)) : min(H,(y2+lineWidth))  ,  max(1,(x1-lineWidth)) : min((x2+lineWidth),W) , : )  );
sizer(3) = 1;
targetColor = reshape(color,[1,1,3]);
targetColor = repmat(targetColor,sizer);
dest(   max(1,(y2-lineWidth)) : min(H,(y2+lineWidth))  ,  max(1,(x1-lineWidth)) : min((x2+lineWidth),W) , : ) = targetColor;
%left
sizer= size(dest(   max(1,(y1-lineWidth)) : min(H,(y2+lineWidth))    ,   max(1,(x1-lineWidth)) : min(W,(x1+lineWidth)), :  ));
sizer(3) = 1;
targetColor = reshape(color,[1,1,3]);
targetColor = repmat(targetColor,sizer);
dest(   max(1,(y1-lineWidth)) : min(H,(y2+lineWidth))    ,   max(1,(x1-lineWidth)) : min(W,(x1+lineWidth)), :  ) = targetColor;
%right
sizer= size(dest(   max(1,(y1-lineWidth)) : min(H,(y2+lineWidth) ) ,   max(1,(x2-lineWidth)) : min(W,(x2+lineWidth)) , :  ) );
sizer(3) = 1;
targetColor = reshape(color,[1,1,3]);
targetColor = repmat(targetColor,sizer);
dest(   max(1,(y1-lineWidth)) : min(H,(y2+lineWidth) ) ,   max(1,(x2-lineWidth)) : min(W,(x2+lineWidth)) , :  ) = targetColor;
end %函数尾