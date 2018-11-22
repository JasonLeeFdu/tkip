
function canvas = paintOnCanvas(oriImg,thisGTRect,thisGT,thisThis,thisLast,thisO,thisOI,IOU_O_last,IOU_OI_last,IOU_O_gt,IOU_OI_gt,DIST_LBP_O,DIST_LBP_OI,thisChoice,framePos)
global onlyMeFatals;
global onlyMeFatalRecord;
%%%%%%%%%%%%%%%%
%   Before the program goes on , everything should be resized
%%%%%%%%%%%%%%%%
% 
% thisGT   =  repmat(reshape(    uint8([255,255,255])    , [1,1,3]),           [333,222,1]           );   % color and shape
% thisThis =  repmat(reshape(    uint8([255 255 255])    , [1,1,3]),           [300,322,1]           );   % color and shape
% thisLast =  repmat(reshape(    uint8([255 255 255])    , [1,1,3]),           [300,322,1]           );   % color and shape
% thisO  =  repmat(reshape(    uint8([255,255,255])    , [1,1,3]),           [300,322,1]           );   % color and shape
% thisOI =  repmat(reshape(    uint8([255 255 255])    , [1,1,3]),           [300,322,1]           );   % color and shape
% IOU_O_last = 0.331321231312;
% IOU_OI_last = 0.4323242345;
% DIST_LBP_O = 456.2345;
% DIST_LBP_OI = 4356.2345;
% thisChoice = 'O';  % 'O' 'I'
% framePos  =12;
THRESH_DLBP = 1000;
THRESH_IOU  = 0.1;
oriImg = imresize(oriImg,[450,600]);
canvas = uint8(zeros(800,600,3));
%%%%%%
if framePos == 1
    onlyMeFatals = [];
    onlyMeFatalRecord = [];
end
thisGTPaint   =  repmat(reshape(    uint8([255,0,0])    , [1,1,3]),           [333,222,1]           );   % color and shape
canvas(1:450,1:600,:) = oriImg;
canvas =  insertText(canvas,[190 450],'GT','FontSize',22,'TextColor','yellow','BoxOpacity',0);
thisGTPaint = imresize(thisGTPaint,[106,106]);
canvas(488:593,168:273,:) = thisGTPaint;
thisGT = imresize(thisGT,[100,100]);
canvas(491:590,171:270,:) = thisGT;

canvas =  insertText(canvas,[190 595],'This','FontSize',20,'TextColor','yellow','BoxOpacity',0);
thisThisPaint =  repmat(reshape(    uint8([255 255 255])    , [1,1,3]),           [300,322,1]           );   % color and shape
thisThisPaint = imresize(thisThisPaint,[106,106]);
canvas(628:733,168:273,:) = thisThisPaint;
thisThis = imresize(thisThis,[100,100]);
canvas(631:730,171:270,:) = thisThis;

canvas =  insertText(canvas,[50 525],'Last','FontSize',22,'TextColor','yellow','BoxOpacity',0);
thisLastPaint =  repmat(reshape(    uint8([180 127 135])    , [1,1,3]),           [300,322,1]           );   % color and shape
thisLastPaint = imresize(thisLastPaint,[106,106]);
canvas(558:663,28:133,:) = thisLastPaint;
thisLast = imresize(thisLast,[100,100]);
canvas(561:660,31:130,:) = thisLast;

%%% line
canvas(451:800,280:282,:)   =  repmat(reshape(    uint8([255,255,0])    , [1,1,3]),           [350,3,1]           );  
%%% right
canvas =  insertText(canvas,[380 450],'O','FontSize',20,'TextColor','yellow','BoxOpacity',0);
thisO = imresize(thisO,[100,100]);
canvas =  insertText(canvas,[490 450],'OI','FontSize',20,'TextColor','yellow','BoxOpacity',0);
canvas =  insertText(canvas,[285 510],'Img','FontSize',20,'TextColor','yellow','BoxOpacity',0);

thisOPaint  =  repmat(reshape(    uint8([255,255,0])    , [1,1,3]),           [300,322,1]           );   % color and shape
thisOPaint = imresize(thisOPaint,[106,106]);
canvas(488:593,338:443,:) = thisOPaint;
thisO = imresize(thisO,[100,100]);
canvas(491:590,341:440,:) = thisO;

thisOIPaint =  repmat(reshape(    uint8([0 0 255])    , [1,1,3]),           [300,322,1]           );   % color and shape
thisOIPaint = imresize(thisOIPaint,[106,106]);
canvas(488:593,468:573,:) = thisOIPaint;
thisOI = imresize(thisOI,[100,100]);
canvas(491:590,471:570,:) = thisOI;

%%
canvas =  insertText(canvas,[285 600],'IOU L','FontSize',16,'TextColor','yellow','BoxOpacity',0);
IOU_O_Std = sprintf('%.4f',IOU_O_last);
IOU_OI_Std =  sprintf('%.4f',IOU_OI_last);
canvas =  insertText(canvas,[350 600],IOU_O_Std,'FontSize',16,'TextColor','yellow','BoxOpacity',0);
canvas =  insertText(canvas,[480 600],IOU_OI_Std,'FontSize',16,'TextColor','yellow','BoxOpacity',0);




canvas =  insertText(canvas,[285 630],'IOU G','FontSize',16,'TextColor','yellow','BoxOpacity',0);
IOU_O_Std_gt = sprintf('%.4f',IOU_O_gt);
IOU_OI_Std_gt =  sprintf('%.4f',IOU_OI_gt);
canvas =  insertText(canvas,[350 630],IOU_O_Std_gt,'FontSize',16,'TextColor','yellow','BoxOpacity',0);
canvas =  insertText(canvas,[480 630],IOU_OI_Std_gt,'FontSize',16,'TextColor','yellow','BoxOpacity',0);




DIST_LBP_O_Std = sprintf('%.2e',DIST_LBP_O);
DIST_LBP_OI_Std = sprintf('%.2e',DIST_LBP_OI);
canvas =  insertText(canvas,[285 660],'DLBP','FontSize',16,'TextColor','yellow','BoxOpacity',0);
canvas =  insertText(canvas,[350 660],DIST_LBP_O_Std,'FontSize',16,'TextColor','yellow','BoxOpacity',0);
canvas =  insertText(canvas,[480 660],DIST_LBP_OI_Std,'FontSize',16,'TextColor','yellow','BoxOpacity',0);

canvas =  insertText(canvas,[283 690],'Choice','FontSize',16,'TextColor','yellow','BoxOpacity',0);
switch  thisChoice
    case 'O'
        canvas(695:714,383:402,:) =  repmat(reshape(    uint8([0,88,0])    , [1,1,3]),           [20,20,1]           );  
    case 'I'
        canvas(695:714,511:530,:) =  repmat(reshape(    uint8([0,220,0])    , [1,1,3]),           [20,20,1]           );  
end
canvas =  insertText(canvas,[283 720],'FATAL:','FontSize',16,'TextColor','yellow','BoxOpacity',0);

bit=false;

if max(IOU_O_gt,IOU_OI_gt) < THRESH_IOU    %% Fail Case catcher
    bit =  true | bit;
else
    bit =  false | bit;
end

% Feature going astray is not easy to implement 
% if min(DIST_LBP_O_Std, thisGTRect) > THRESH_DLBP   ||  max(DIST_LBP_OI_Std, thisGTRect) < THRESH_IOU   %% Fail Case
%     bit =  true | bit;
% else
%     bit =  false | bit;
% end

onlyMeFatalRecord(end+1) = bit;


if length(onlyMeFatalRecord)>3 && onlyMeFatalRecord(end-2)==0 && onlyMeFatalRecord(end-1)==0 && onlyMeFatalRecord(end)==1 
    onlyMeFatals(end+1) = framePos;
    if length(onlyMeFatals)>8
        onlyMeFatals(1) = [];
    end
end

if(length(onlyMeFatals)>=8)
    canvas =  insertText(canvas,[372 720], num2str(uint16(onlyMeFatals(1))),'FontSize',16,'TextColor','yellow','BoxOpacity',0);
    canvas =  insertText(canvas,[500 720], num2str(uint16(onlyMeFatals(2))),'FontSize',16,'TextColor','yellow','BoxOpacity',0);
    canvas =  insertText(canvas,[372 740], num2str(uint16(onlyMeFatals(3))),'FontSize',16,'TextColor','yellow','BoxOpacity',0);
    canvas =  insertText(canvas,[500 740], num2str(uint16(onlyMeFatals(4))),'FontSize',16,'TextColor','yellow','BoxOpacity',0);
    canvas =  insertText(canvas,[372 760], num2str(uint16(onlyMeFatals(5))),'FontSize',16,'TextColor','yellow','BoxOpacity',0);
    canvas =  insertText(canvas,[500 760], num2str(uint16(onlyMeFatals(6))),'FontSize',16,'TextColor','yellow','BoxOpacity',0);
    canvas =  insertText(canvas,[372 780], num2str(uint16(onlyMeFatals(7))),'FontSize',16,'TextColor','yellow','BoxOpacity',0);
    canvas =  insertText(canvas,[500 780], num2str(uint16(onlyMeFatals(8))),'FontSize',16,'TextColor','yellow','BoxOpacity',0); 
elseif  (length(onlyMeFatals)==7)
    canvas =  insertText(canvas,[372 720], num2str(uint16(onlyMeFatals(1))),'FontSize',16,'TextColor','yellow','BoxOpacity',0);
    canvas =  insertText(canvas,[500 720], num2str(uint16(onlyMeFatals(2))),'FontSize',16,'TextColor','yellow','BoxOpacity',0);
    canvas =  insertText(canvas,[372 740], num2str(uint16(onlyMeFatals(3))),'FontSize',16,'TextColor','yellow','BoxOpacity',0);
    canvas =  insertText(canvas,[500 740], num2str(uint16(onlyMeFatals(4))),'FontSize',16,'TextColor','yellow','BoxOpacity',0);
    canvas =  insertText(canvas,[372 760], num2str(uint16(onlyMeFatals(5))),'FontSize',16,'TextColor','yellow','BoxOpacity',0);
    canvas =  insertText(canvas,[500 760], num2str(uint16(onlyMeFatals(6))),'FontSize',16,'TextColor','yellow','BoxOpacity',0);
    canvas =  insertText(canvas,[372 780], num2str(uint16(onlyMeFatals(7))),'FontSize',16,'TextColor','yellow','BoxOpacity',0);   
elseif  (length(onlyMeFatals)==6)
    canvas =  insertText(canvas,[372 720], num2str(uint16(onlyMeFatals(1))),'FontSize',16,'TextColor','yellow','BoxOpacity',0);
    canvas =  insertText(canvas,[500 720], num2str(uint16(onlyMeFatals(2))),'FontSize',16,'TextColor','yellow','BoxOpacity',0);
    canvas =  insertText(canvas,[372 740], num2str(uint16(onlyMeFatals(3))),'FontSize',16,'TextColor','yellow','BoxOpacity',0);
    canvas =  insertText(canvas,[500 740], num2str(uint16(onlyMeFatals(4))),'FontSize',16,'TextColor','yellow','BoxOpacity',0);
    canvas =  insertText(canvas,[372 760], num2str(uint16(onlyMeFatals(5))),'FontSize',16,'TextColor','yellow','BoxOpacity',0);
    canvas =  insertText(canvas,[500 760], num2str(uint16(onlyMeFatals(6))),'FontSize',16,'TextColor','yellow','BoxOpacity',0);
elseif  (length(onlyMeFatals)==5)
 	canvas =  insertText(canvas,[372 720], num2str(uint16(onlyMeFatals(1))),'FontSize',16,'TextColor','yellow','BoxOpacity',0);
    canvas =  insertText(canvas,[500 720], num2str(uint16(onlyMeFatals(2))),'FontSize',16,'TextColor','yellow','BoxOpacity',0);
    canvas =  insertText(canvas,[372 740], num2str(uint16(onlyMeFatals(3))),'FontSize',16,'TextColor','yellow','BoxOpacity',0);
    canvas =  insertText(canvas,[500 740], num2str(uint16(onlyMeFatals(4))),'FontSize',16,'TextColor','yellow','BoxOpacity',0);
    canvas =  insertText(canvas,[372 760], num2str(uint16(onlyMeFatals(5))),'FontSize',16,'TextColor','yellow','BoxOpacity',0);
elseif  (length(onlyMeFatals)==4)
   	canvas =  insertText(canvas,[372 720], num2str(uint16(onlyMeFatals(1))),'FontSize',16,'TextColor','yellow','BoxOpacity',0);
    canvas =  insertText(canvas,[500 720], num2str(uint16(onlyMeFatals(2))),'FontSize',16,'TextColor','yellow','BoxOpacity',0);
    canvas =  insertText(canvas,[372 740], num2str(uint16(onlyMeFatals(3))),'FontSize',16,'TextColor','yellow','BoxOpacity',0);
    canvas =  insertText(canvas,[500 740], num2str(uint16(onlyMeFatals(4))),'FontSize',16,'TextColor','yellow','BoxOpacity',0);
elseif  (length(onlyMeFatals)==3)
	canvas =  insertText(canvas,[372 720], num2str(uint16(onlyMeFatals(1))),'FontSize',16,'TextColor','yellow','BoxOpacity',0);
    canvas =  insertText(canvas,[500 720], num2str(uint16(onlyMeFatals(2))),'FontSize',16,'TextColor','yellow','BoxOpacity',0);
    canvas =  insertText(canvas,[372 740], num2str(uint16(onlyMeFatals(3))),'FontSize',16,'TextColor','yellow','BoxOpacity',0);
elseif  (length(onlyMeFatals)==2)
	canvas =  insertText(canvas,[372 720], num2str(uint16(onlyMeFatals(1))),'FontSize',16,'TextColor','yellow','BoxOpacity',0);
    canvas =  insertText(canvas,[500 720], num2str(uint16(onlyMeFatals(2))),'FontSize',16,'TextColor','yellow','BoxOpacity',0);
elseif  (length(onlyMeFatals)==1)
	canvas =  insertText(canvas,[372 720], num2str(uint16(onlyMeFatals(1))),'FontSize',16,'TextColor','yellow','BoxOpacity',0);
end

end


% 
% imwrite(canvas,'/home/winston/Desktop/1.bmp')
% imshow(canvas);
% 

function overlap = IOU (rect1,rect2) % lefttop widh height
leftA = rect1(:,1);
bottomA = rect1(:,2);
rightA = leftA + rect1(:,3) - 1;
topA = bottomA + rect1(:,4) - 1;

leftB = rect2(:,1);
bottomB = rect2(:,2);
rightB = leftB + rect2(:,3) - 1;
topB = bottomB + rect2(:,4) - 1;

tmp = (max(0, min(rightA, rightB) - max(leftA, leftB)+1 )) .* (max(0, min(topA, topB) - max(bottomA, bottomB)+1 ));
areaA = rect1(:,3) .* rect1(:,4);
areaB = rect2(:,3) .* rect2(:,4);
overlap = tmp./(areaA+areaB-tmp);
end


