set100 = ConfigSeqs100;
set50  = ConfigSeqs;
choice = zeros(1,100);

for i=1:100
   flag = false;
   for j=1:51
      if strcmp(set100{i}.name,set50{j}.name)
            flag = true;
            break;
      end
   end
   if flag
       choice(i) = 1;
   end
end

disp('Finished');