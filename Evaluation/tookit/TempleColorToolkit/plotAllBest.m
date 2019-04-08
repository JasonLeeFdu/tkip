clc;
clear;

numSeq=129;
trackerSet = cell(0,1);
seqSet=cell(numSeq,1);
gtSet=cell(numSeq,1);
legendNames=cell(0,1);



trackerSet{1}= 'MEEM';
trackerSet{2}= 'MCPF';
trackerSet{3}= 'DSLT';
trackerSet{4}= 'CCOT';
trackerSet{5}= 'VITALAdv';
trackerSet{6}= 'ECO';
trackerSet{7}= 'MCCT';
numTracker = length(trackerSet);


seqSet{1}='Basketball';
seqSet{2}='Bicycle';
seqSet{3}='Biker';
seqSet{4}='Bird';
seqSet{5}='Board';
seqSet{6}='Bolt';
seqSet{7}='Boy';
seqSet{8}='CarDark';
seqSet{9}='CarScale';
seqSet{10}='Coke';
seqSet{11}='Couple';
seqSet{12}='Crossing';
seqSet{13}='Cup';
seqSet{14}='David';
seqSet{15}='David3';
seqSet{16}='Deer';
seqSet{17}='Diving';
seqSet{18}='Doll';
seqSet{19}='FaceOcc1';
seqSet{20}='Football1';
seqSet{21}='Girl';
seqSet{22}='Girlmov';
seqSet{23}='Gym';
seqSet{24}='Hand';
seqSet{25}='Iceskater';
seqSet{26}='Ironman';
seqSet{27}='Jogging1';
seqSet{28}='Jogging2';
seqSet{29}='Juice';
seqSet{30}='Lemming';
seqSet{31}='Liquor';
seqSet{32}='Matrix';
seqSet{33}='MotorRolling';
seqSet{34}='MountainBike';
seqSet{35}='Panda';
seqSet{36}='Shaking';
seqSet{37}='Singer1';
seqSet{38}='Singer2';
seqSet{39}='Skating1';
seqSet{40}='Skating2';
seqSet{41}='Skiing';
seqSet{42}='Soccer';
seqSet{43}='Subway';
seqSet{44}='Sunshade';
seqSet{45}='Tiger1';
seqSet{46}='Tiger2';
seqSet{47}='Torus';
seqSet{48}='Trellis';
seqSet{49}='Walking';
seqSet{50}='Walking2';
seqSet{51}='Woman';
seqSet{52}='Airport_ce';
seqSet{53}='Baby_ce';
seqSet{54}='Badminton_ce1';
seqSet{55}='Badminton_ce2';
seqSet{56}='Basketball_ce1';
seqSet{57}='Basketball_ce2';
seqSet{58}='Basketball_ce3';
seqSet{59}='Bike_ce1';
seqSet{60}='Bike_ce2';
seqSet{61}='Bikeshow_ce';
seqSet{62}='Boat_ce1';
seqSet{63}='Boat_ce2';
seqSet{64}='Busstation_ce1';
seqSet{65}='Busstation_ce2';
seqSet{66}='Carchasing_ce1';
seqSet{67}='Carchasing_ce3';
seqSet{68}='Carchasing_ce4';
seqSet{69}='Eagle_ce';
seqSet{70}='Electricalbike_ce';
seqSet{71}='Face_ce';
seqSet{72}='Guitar_ce1';
seqSet{73}='Guitar_ce2';
seqSet{74}='Hurdle_ce1';
seqSet{75}='Hurdle_ce2';
seqSet{76}='Kite_ce1';
seqSet{77}='Kite_ce2';
seqSet{78}='Kite_ce3';
seqSet{79}='Kobe_ce';
seqSet{80}='Logo_ce';
seqSet{81}='Messi_ce';
seqSet{82}='Michaeljackson_ce';
seqSet{83}='Motorbike_ce';
seqSet{84}='Plane_ce2';
seqSet{85}='Railwaystation_ce';
seqSet{86}='Singer_ce1';
seqSet{87}='Singer_ce2';
seqSet{88}='Skating_ce1';
seqSet{89}='Skating_ce2';
seqSet{90}='Skiing_ce';
seqSet{91}='Skyjumping_ce';
seqSet{92}='Spiderman_ce';
seqSet{93}='Suitcase_ce';
seqSet{94}='Surf_ce1';
seqSet{95}='Surf_ce2';
seqSet{96}='Surf_ce3';
seqSet{97}='Surf_ce4';
seqSet{98}='Tennis_ce1';
seqSet{99}='Tennis_ce2';
seqSet{100}='Tennis_ce3';
seqSet{101}='Toyplane_ce';
seqSet{102}='Ball_ce1';
seqSet{103}='Ball_ce2';
seqSet{104}='Ball_ce3';
seqSet{105}='Ball_ce4';
seqSet{106}='Bee_ce';
seqSet{107}='Charger_ce';
seqSet{108}='Cup_ce';
seqSet{109}='Face_ce2';
seqSet{110}='Fish_ce1';
seqSet{111}='Fish_ce2';
seqSet{112}='Hand_ce1';
seqSet{113}='Hand_ce2';
seqSet{114}='Microphone_ce1';
seqSet{115}='Microphone_ce2';
seqSet{116}='Plate_ce1';
seqSet{117}='Plate_ce2';
seqSet{118}='Pool_ce1';
seqSet{119}='Pool_ce2';
seqSet{120}='Pool_ce3';
seqSet{121}='Ring_ce';
seqSet{122}='Sailor_ce';
seqSet{123}='SuperMario_ce';
seqSet{124}='TableTennis_ce';
seqSet{125}='TennisBall_ce';
seqSet{126}='Thunder_ce';
seqSet{127}='Yo-yos_ce1';
seqSet{128}='Yo-yos_ce2';
seqSet{129}='Yo-yos_ce3';
bestColorSet = cell(numTracker,1);
bestColorSet{1}= 'LAB';
bestColorSet{2}= 'RGB';






colorValue=cell(numTracker,1);
colorValue{1}=[0 0 1];
colorValue{2}=[1 0 0];
colorValue{3}=[163 73 164]/255;%purple
colorValue{4}=[255 127 39]/255;%orange
colorValue{5}=[1 0 1];%magenta
colorValue{6}=[34 139 34]/255;
colorValue{7}=[210 105 30]/255;
colorValue{8}=[139 28 98]/255;
colorValue{9}=[139 0 139]/255;% dark magenta
colorValue{10}=[0 255 255]/255;% cyan
colorValue{11}= [0 100 0]/255; % dark green
colorValue{12}= [1 1 0]; % yellow
colorValue{13}= [255 215 0]/255; % dark cyan
colorValue{14}= [105 105 105]/255;
colorValue{15}= [0 1 0];
colorValue{16}= [136 0 21]/255; %dark red
colorValue{17}= [0 0 1];
colorValue{18}= [1 0 0];
colorValue{19}= [77 235 255]/255;



iBestColorSet = cell(numTracker,1);
iBestColorSet{1}= 'LAB';
iBestColorSet{2}= 'RGB';


lineType = cell(numTracker,1);
lineType{1}='-';
lineType{2}='-';
lineType{3}='-';
lineType{4}='-';
lineType{5}='-';
lineType{6}='-';
lineType{7}='-';
lineType{8}='-';
lineType{9}='-';
lineType{10}='-';
lineType{11}='-';
lineType{12}='-';
lineType{13}='-';
lineType{14}='-';
lineType{15}='-';
lineType{16}='-';
lineType{17}='--';
lineType{18}='--';
lineType{19}='--';

totalFrame=zeros(numTracker,1);
auc=zeros(numTracker,1);
thresholdSet=0:0.05:1;
thresholdSetError=0:50;
succRate=zeros(numTracker,numSeq,length(thresholdSet));
preRate=zeros(numTracker,numSeq,length(thresholdSetError));

for i=1:numSeq
    gtFile=strcat('groundtruth/',seqSet{i},'_gt.txt');
    gtSet{i}=dlmread(gtFile);
end

for i=1:numTracker
    tracker = trackerSet{i};
    for j=1:numSeq
        fprintf('processing %d %d\n',i,j);
        if i<= 2
            colorModel=bestColorSet{i};
            rtFile=strcat('results/',tracker,'/',seqSet{j},'_',tracker,'_',colorModel,'.txt');
        else
            rtFile=strcat('results/',tracker,'/',seqSet{j},'_',tracker,'.txt');
        end
        rt=load(rtFile);
        [M1,N1]=size(gtSet{j});
        [M2,N2]=size(rt);
        for tpi = 2:M2
            r = rt(tpi,:);
            rAnno = gtSet{j}(tpi,:);
            if (isnan(r) | r(3)<=0 | r(4)<=0)&(~isnan(rAnno))
                rt(tpi,:)=rt(tpi-1,:);
            end
        end
        rt(1,:)=gtSet{j}(1,:);
        if N1~=4 || N2~=4
            error('The number of columns has to be 4');
        end
        if M1<M2
            M=M1;
        else
            M=M2;
        end
        
        totalFrame(i,1)=totalFrame(i,1)+M;
        overlaps=[];
        overlaps=calOverlap(rt(1:M,:),gtSet{j}(1:M,:));
        for k=1:length(thresholdSet)
            tpError=zeros(size(overlaps,1),1);
            tpError=overlaps>thresholdSet(k);
            tpSum=sum(tpError);
            succRate(i,j,k)=tpSum/M;
        end
        gt=gtSet{j};
        centerGT = [gt(1:M,1)+(gt(1:M,3)-1)/2 gt(1:M,2)+(gt(1:M,4)-1)/2];
        centerRT = [rt(1:M,1)+(rt(1:M,3)-1)/2 rt(1:M,2)+(rt(1:M,4)-1)/2];
        dist = centerGT-centerRT;
        dist = dist.*dist;
        dist = dist(:,1)+dist(:,2);
        dist = sqrt(dist);
        for k=1:length(thresholdSetError)
            tpError=dist<=thresholdSetError(k);
            tpSum=sum(tpError);
            preRate(i,j,k)=tpSum/M;
        end
    end
end
finalSuccRate=zeros(numTracker,length(thresholdSet));
for i=1:numTracker
    
    for j=1:numSeq
        for k=1:length(thresholdSet)
            finalSuccRate(i,k)=finalSuccRate(i,k)+succRate(i,j,k);
        end
    end
    for k=1:length(thresholdSet)
        finalSuccRate(i,k)=finalSuccRate(i,k)/numSeq;
    end
    auc(i)=mean(finalSuccRate(i,:));
    strauc=sprintf(' [%.4f]',auc(i));
	if i <= 2 
        legendNames{i}=strcat(trackerSet{i},'(',iBestColorSet{i},')',strauc);
    else
        legendNames{i}=strcat(trackerSet{i},strauc);
    end
end

[sauc,indexauc]=sort(auc,'descend');
figure1=figure;
box on;
hold on;
finalSuccRate = single(finalSuccRate);
thresholdSet = single(thresholdSet);
for idx =1:length(trackerSet)
   plot(thresholdSet,finalSuccRate(indexauc(idx),:),lineType{indexauc(idx)},'LineWidth',4,'Color',colorValue{indexauc(idx)});   
end

legend(legendNames{indexauc(1)},legendNames{indexauc(2)},legendNames{indexauc(3)},legendNames{indexauc(4)},...
    legendNames{indexauc(5)},legendNames{indexauc(6)},legendNames{indexauc(7)},'Location','EastOutside');%,'FontWeight','bold');
set(gca,'FontSize',30);
set(gca,'FontWeight','bold');

set(gcf,'Position',[100 100 1500 800]);
titlename=strcat('Success plots');
title(titlename,'FontSize',40);
xlabel('Overlap threshold','FontSize',40);
ylabel('Success rate','FontSize',40);
fprintf('total frames:%d\n',totalFrame(1,1));
imwrite(frame2im(getframe(gcf)),'Succ_comparison_best.png');

finalPreRate=zeros(numTracker,length(thresholdSetError));
tpInx = find(thresholdSetError == 20);

for i=1:numTracker
    for j=1:numSeq
        for k=1:length(thresholdSetError)
            finalPreRate(i,k)=finalPreRate(i,k)+preRate(i,j,k);
        end
    end
    for k=1:length(thresholdSetError)
        finalPreRate(i,k)=finalPreRate(i,k)/numSeq;
    end
    strauc=sprintf(' [%.4f]',finalPreRate(i,tpInx));
    if i <= 2 
        legendNames{i}=strcat(trackerSet{i},'(',iBestColorSet{i},')',strauc);
    else
        legendNames{i}=strcat(trackerSet{i},strauc);
    end
end
tpPreRate = finalPreRate(:,tpInx);
[spre,indexpre]=sort(tpPreRate,'descend');
figure2=figure;
box on;
hold on;
for idx =1:length(trackerSet)
   plot(thresholdSetError,finalPreRate(indexpre(idx),:),lineType{indexpre(idx)},'LineWidth',4,'Color',colorValue{indexpre(idx)});   
end

legend(legendNames{indexpre(1)},legendNames{indexpre(2)},legendNames{indexpre(3)},legendNames{indexpre(4)},...
    legendNames{indexpre(5)},legendNames{indexpre(6)},legendNames{indexauc(7)},'Location','EastOutside');
set(gca,'FontSize',30);
set(gca,'FontWeight','bold');


set(gcf,'Position',[100 100 1500 800]);
titlename=strcat('Precision plots');
title(titlename,'FontSize',40);
xlabel('Distance threshold','FontSize',40);
ylabel('Precision','FontSize',40);
imwrite(frame2im(getframe(gcf)),'Pre_comparison_best.png');
fprintf('finished...\n');


