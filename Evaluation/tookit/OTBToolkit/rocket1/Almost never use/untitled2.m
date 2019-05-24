path = '/home/winston/Desktop/datas';
fns = dir(path);
for i=3:length(fns)
    oldFn  = fullfile(path,fns(i).name);
    nameToken = sprintf('%05d.jpg',i-2);
    newFn  = fullfile(path,nameToken);
    movefile(oldFn,newFn);
end