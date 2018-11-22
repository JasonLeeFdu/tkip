function [res,fps] = ModuleSimpleRun(moduleName,imgSetOri,init_rect)
% module configuration
MD_Ori = [];
nFrames = length(imgSetOri);
res = zeros(nFrames,4);
res(1,:) = init_rect;
fps = 0;
Combine_OOIt = init_rect;

switch lower(moduleName)
    case 'vital'
        MD_Ori = VITAL_MODULE(imgSetOri,Combine_OOIt);
    case 'strcf'
        MD_Ori = STRCF_MODULE(imgSetOri,Combine_OOIt);
end
% core algorithms
tic
s = toc;
for t = 2:nFrames
   Res_O_t = MD_Ori.trackNext(imgSetOri{t},Combine_OOIt);
   res(t,:) = Res_O_t;
   Combine_OOIt = Res_O_t;
   if mod(t,30) == 0
       fprintf('\n');
       fprintf('%03d',floor(t));
   end
   fprintf('.');
end
e = toc;
fps = (nFrames-1) / (e - s);
fprintf('\n\n');
end



