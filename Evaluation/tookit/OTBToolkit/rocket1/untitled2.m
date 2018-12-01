function  untitled2( )

rect = [4,2,3,2];
rect = reshape(rect,[1,4]);
rect2 = expandSearchArea(rect,2,5,40);
rect2


end


function rect2 = expandSearchArea(rect,r,H,W)  % lefttop widh height
l1 = rect(:,1);
t1 = rect(:,2);
w1 = rect(:,3);
h1 = rect(:,4);
cx = l1 + (w1 -1)/2;
cy = t1 + (h1 -1)/2;
w2 = w1 * r;
h2 = h1 * r;
l2 = cx - (w2 - 1)/2;
t2 = cy - (h2 - 1)/2;

Wmax = W - l2 + 1;
Hmax = H - t2 + 1;
w2   = max(1,min(Wmax,w2));
h2   = max(1,min(Hmax,h2));


rect2 = [l2;t2;w2;h2];
rect2 = round(rect2);
end
