a = dir('/home/winston/Datasets/Tracking/Original/OTB100');
for i = 3:length(a)
  fprintf("struct('name','%s','path',strcat(basePath,'%s/img/')),...",a(i).name,a(i).name)
  fprintf('\n');
end