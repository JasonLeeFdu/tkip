function PlotDrawSave(dsRate,idxTrk,plotDrawStyle,pmSIP,idxSeqSet,rankingType,rankIdx,nameTrkAll,thresholdSet,titleName,xLabelName,yLabelName,figName,setNameOrder)
% dsRate,
% numTrk：              Tracker的个数           
% plotDrawStyle：       划线的样式，如前文所述
% pmSIP：               结果矩阵： #trk   #video  #threshes  #(Std2,Ideal2,StdInterp2)
% idxSeqSet:            本图对哪类“标签”的视频集合感兴趣进行统计？
% rankNum：             无用
% rankingType：         算法性能(集合性能)排名方法，有threshold\AUC
% rankIdx:              暂不清楚。与中位数统计有关系
% nameTrkAll：          所有tracker的名字
% thresholdSet：        图像横轴采样点
% titleName：           图像题目名称
% xLabelName：          X名称
% yLabelName：          y名称
% figName：             保存图片名称
% metricType：          度量方式，有error 与 overlap


aveSuccessRate11=[];

scrsz = get(0,'ScreenSize');


numDSType = size(pmSIP,4);
rankNum = numDSType;
%setNameOrder = {sprintf('Std%d',dsRate),sprintf('Ideal%d',dsRate),sprintf('StdInterp%d',dsRate)};


for idxDSType=1:numDSType
    %each row is the sr plot of one sequence
    tmp=pmSIP(idxTrk, idxSeqSet,:,idxDSType);%every trk, selected movie,all thresh
    aa=reshape(tmp,[length(idxSeqSet),size(pmSIP,3)]); % 
    aa=aa(sum(aa,2)>eps,:);
    bb=mean(aa);
    switch rankingType
        case 'AUC'
            perf(idxDSType) = mean(bb);
        case 'threshold'
            perf(idxDSType) = bb(rankIdx);
    end
    
    
end

[tmp,indexSort]=sort(perf,'descend');

i=1;
AUC=[];

fontSize = 16;
fontSizeLegend = 10;

figure1 = figure;

axes1 = axes('Parent',figure1,'FontSize',14);


for idxDSType=indexSort(1:rankNum)

    tmp=pmSIP(idxTrk,idxSeqSet,:,idxDSType);
    aa=reshape(tmp,[length(idxSeqSet),size(pmSIP,3)]);
    aa=aa(sum(aa,2)>eps,:);
    bb=mean(aa);
    
    switch rankingType
        case 'AUC'
            score = mean(bb);
            tmp=sprintf('%.3f', score);
            suffix = 'AUC';
        case 'threshold'
            score = bb(rankIdx);
            tmp=sprintf('%.3f', score);
            suffix = 'threshold';
    end    
    
    tmpName{i} = [nameTrkAll{idxTrk}  setNameOrder{idxDSType}  ' ['  suffix ': '  tmp ']'];
    h(i) = plot(thresholdSet,bb,'color',plotDrawStyle{idxDSType}.color, 'lineStyle', plotDrawStyle{i}.lineStyle,'lineWidth', 4,'Parent',axes1);
    hold on
    i=i+1;
end


legend1=legend(tmpName,'Interpreter', 'none','fontsize',fontSizeLegend);
title(titleName,'fontsize',fontSize);
xlabel(xLabelName,'fontsize',fontSize);
ylabel(yLabelName,'fontsize',fontSize);
hold off

saveas(gcf,figName,'png');

end
