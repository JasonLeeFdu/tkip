function dense = BarToDense(resBar,bin,whetherPlot,Xs)
num = length(resBar);
total = sum(resBar);
dense = zeros(1,num);

for k = 1:length(resBar)
    n  = sum(resBar(1:k));
    pk = n / total;
    dense(k) = pk;
end


if whetherPlot
   if isempty(bin)
       x = 1:num;
   else
       x = bin;
   end
   
   
   plot(x,dense);
%   Xs = [];
   %%% get the info of dense by x
%    for i = 1:length(Rs)
%       tmp = Rs(i);
%       for k = 1:length(dense)
%         if dense(k) > tmp
%             break;
%         end
%       end
%       Xs(end + 1) = (x(k-1)+x(k))/2;
%    end
   
   
   if ~isempty(Xs)
       numXs = length(Xs);
       for u = 1:numXs
           hold on;
           plot([Xs(u) Xs(u)],[0 1]);       
       end
       

   end
end


end
