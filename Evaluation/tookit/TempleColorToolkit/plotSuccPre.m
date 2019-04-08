clc;
clear;

numSeq=129;
numColorModel=10;
numTracker=16;
seqSet=cell(numSeq,1);
colorSet=cell(numColorModel,1);
icolorSet=cell(numColorModel,1);
gtSet=cell(numSeq,1);
legnedNames=cell(numColorModel,1);
colorValue=cell(numColorModel,1);
trackerSet=cell(numTracker,1);

trackerSet{1}='ASLA';
trackerSet{2}='CPF';
trackerSet{3}='CSK';
trackerSet{4}='CT';
trackerSet{5}='DFT';
trackerSet{6}='FCT';
trackerSet{7}='Frag';
trackerSet{8}='IVT';
trackerSet{9}='KCF';
trackerSet{10}='L1APG';
trackerSet{11}='LOT';
trackerSet{12}='MEEM';
trackerSet{13}='MIL';
trackerSet{14}='OAB';
trackerSet{15}='SemiT';
trackerSet{16}='Struck';

icolorSet{1}='GRAY';
icolorSet{2}='OPPONENT';
icolorSet{3}='NOPPONENT';
icolorSet{4}='RGB';
icolorSet{5}='NRGB';
icolorSet{6}='TRGB';
icolorSet{7}='HSV';
icolorSet{8}='COPPONENT';
icolorSet{9}='HUE';
icolorSet{10}='LAB';

colorSet{1}='Intensity';
colorSet{2}='OPP';
colorSet{3}='N-OPP';
colorSet{4}='RGB';
colorSet{5}='rg';
colorSet{6}='TRGB';
colorSet{7}='HSV';
colorSet{8}='C-OPP';
colorSet{9}='Hue';
colorSet{10}='LAB';

colorValue{1}=[0 0 0];
colorValue{2}=[1 0 0];
colorValue{3}=[163 73 164]/255;%purple
colorValue{4}=[255 127 39]/255;%orange
colorValue{5}=[1 0 1];%pink
colorValue{6}=[136 0 21]/255;% dark red
colorValue{7}=[0 0 1];
colorValue{8}=[0 255 255]/255;% cyan
colorValue{9}=[0 100 0]/255;% dark magenta
colorValue{10}=[0 1 0];

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

if ~exist('figures','dir')
    mkdir('figures');
end

for i=1:numSeq
    gtFile=strcat('groundtruth\\',seqSet{i},'_gt.txt');
    gtSet{i}=dlmread(gtFile);
end

for ti=1:numTracker
    tracker=trackerSet{ti};
    fprintf('processing tracker: %s\n',tracker);
    totalFrame=zeros(numColorModel,1);
    auc=zeros(numColorModel,1);
    thresholdSet=0:0.05:1;
    thresholdSetError=0:50;
    succRate=zeros(numColorModel,numSeq,length(thresholdSet));
    preRate=zeros(numColorModel,numSeq,length(thresholdSetError));
    for i=1:numColorModel
        for j=1:numSeq
            colorModel=icolorSet{i};
            rtFile=strcat('results\\',tracker,'\\',seqSet{j},'_',tracker,'_',colorModel,'.txt');
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
                M=M1
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
    finalSuccRate=zeros(numColorModel,length(thresholdSet));
    for i=1:numColorModel
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
        legnedNames{i}=strcat(colorSet{i},strauc);
    end
    
    [sauc,indexauc]=sort(auc,'descend');
    
    figure1=figure;
    box on;
    hold on;
    ylim([0,0.8]);
    plot(thresholdSet,finalSuccRate(indexauc(1),:),'-','LineWidth',4,'Color',colorValue{indexauc(1)});
    plot(thresholdSet,finalSuccRate(indexauc(2),:),'-','LineWidth',4,'Color',colorValue{indexauc(2)});
    plot(thresholdSet,finalSuccRate(indexauc(3),:),'-','LineWidth',4,'Color',colorValue{indexauc(3)});
    plot(thresholdSet,finalSuccRate(indexauc(4),:),'-','LineWidth',4,'Color',colorValue{indexauc(4)});
    plot(thresholdSet,finalSuccRate(indexauc(5),:),'-','LineWidth',4,'Color',colorValue{indexauc(5)});
    plot(thresholdSet,finalSuccRate(indexauc(6),:),'-','LineWidth',4,'Color',colorValue{indexauc(6)});
    plot(thresholdSet,finalSuccRate(indexauc(7),:),'-','LineWidth',4,'Color',colorValue{indexauc(7)});
    plot(thresholdSet,finalSuccRate(indexauc(8),:),'-','LineWidth',4,'Color',colorValue{indexauc(8)});
    plot(thresholdSet,finalSuccRate(indexauc(9),:),'-','LineWidth',4,'Color',colorValue{indexauc(9)});
    plot(thresholdSet,finalSuccRate(indexauc(10),:),'-','LineWidth',4,'Color',colorValue{indexauc(10)});
    
    
    legend(legnedNames{indexauc(1)},legnedNames{indexauc(2)},legnedNames{indexauc(3)},legnedNames{indexauc(4)},...
        legnedNames{indexauc(5)},legnedNames{indexauc(6)},legnedNames{indexauc(7)},legnedNames{indexauc(8)},legnedNames{indexauc(9)},legnedNames{indexauc(10)},'Location','NorthEast');
    set(gca,'FontSize',25);
    set(gcf,'Position',[10 10 1200 960]);
    titlename=strcat('Success plots of',32,tracker);
    title(titlename,'FontSize',35);
    xlabel('Overlap threshold','FontSize',35);
    ylabel('Success rate','FontSize',35);
    saveFileName = ['figures//' tracker '_Succ.png'];
    imwrite(frame2im(getframe(gcf)),saveFileName);
    
    finalPreRate=zeros(numColorModel,length(thresholdSetError));
    tpInx = find(thresholdSetError == 20);
    
    for i=1:numColorModel
        for j=1:numSeq
            for k=1:length(thresholdSetError)
                finalPreRate(i,k)=finalPreRate(i,k)+preRate(i,j,k);
            end
        end
        for k=1:length(thresholdSetError)
            finalPreRate(i,k)=finalPreRate(i,k)/numSeq;
        end
        strauc=sprintf(' [%.4f]',finalPreRate(i,tpInx));
        legnedNames{i}=strcat(colorSet{i},strauc);
    end
    tpPreRate = finalPreRate(:,tpInx);
    [spre,indexpre]=sort(tpPreRate,'descend');
    figure2=figure;
    box on;
    hold on;
    ylim([0,0.8]);
    plot(thresholdSetError,finalPreRate(indexpre(1),:),'-','LineWidth',4,'Color',colorValue{indexpre(1)});
    plot(thresholdSetError,finalPreRate(indexpre(2),:),'-','LineWidth',4,'Color',colorValue{indexpre(2)});
    plot(thresholdSetError,finalPreRate(indexpre(3),:),'-','LineWidth',4,'Color',colorValue{indexpre(3)});
    plot(thresholdSetError,finalPreRate(indexpre(4),:),'-','LineWidth',4,'Color',colorValue{indexpre(4)});
    plot(thresholdSetError,finalPreRate(indexpre(5),:),'-','LineWidth',4,'Color',colorValue{indexpre(5)});
    plot(thresholdSetError,FlagVid = false;



<<<<<<< HEAD
for idxVideo= 3:3:length(videosList)% 对于每一个视频(此处可以使用多进程)  
=======

for idxVideo= 3:4:length(videosList)% 对于每一个视频(此处可以使用多进程)  
>>>>>>> 0443d960856655cfb79d59908cbeead76d0e9824
     disp([ '================== AdvBaseline Validation check fixed version1: ADV' ' --- ' ', ' num2str(idxVideo) '_' videosList(idxVideo).name '================== '])       
     completeFileName = sprintf('%s_%s_Adv.mat',videosList(idxVideo).name,trackers{1}.name);
     if exist(fullfile(resPathBase,completeFileName),'file')  && (~overWrite)
          fprintf([ 'Best Result --- '  num2str(idxVideo) '_' videosList(idxVideo).name]);
          fprintf(' is DONE! \n'); 
          continue;
     endfinalPreRate(indexpre(6),:),'-','LineWidth',4,'Color',colorValue{indexpre(6)});
    plot(thresholdSetError,finalPreRate(indexpre(7),:),'-','LineWidth',4,'Color',colorValue{indexpre(7)});
    plot(thresholdSetError,finalPreRate(indexpre(8),:),'-','LineWidth',4,'Color',colorValue{indexpre(8)});
    plot(thresholdSetError,finalPreRate(indexpre(9),:),'-','LineWidth',4,'Color',colorValue{indexpre(9)});
    plot(thresholdSetError,finalPreRate(indexpre(10),:),'-','LineWidth',4,'Color',colorValue{indexpre(10)});
    
    legend(legnedNames{indexpre(1)},legnedNames{indexpre(2)},legnedNames{indexpre(3)},legnedNames{indexpre(4)},...
        legnedNames{indexpre(5)},legnedNames{indexpre(6)},legnedNames{indexpre(7)},legnedNames{indexpre(8)},legnedNames{indexpre(9)},legnedNames{indexpre(10)},'Location','SouthEast');
    set(gca,'FontSize',25);
    set(gcf,'Position',[10 10 1200 960]);
    titlename=strcat('Precision plots of',32,tracker);
    title(titlename,'FontSize',35);
    xlabel('Distance threshold','FontSize',35);
    ylabel('Precision','FontSize',35);
    saveFileName = ['figures//' tracker '_Pre.png'];
    imwrite(frame2im(getframe(gcf)),saveFileName);
end
fprintf('finished...\n');
