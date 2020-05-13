function [mask] = segmenta_strand_gray(im)

im = im2uint8(normalizzaImg(im));

            
%---------------------------------------------------------------
% t = edge(im, 'roberts', 0.012);
% t2 = morf(t, 'dilate', 'disk', 3);
% %t3 = morf(t2, 'openclose', 'disk', 5);
% t3 = morf(t2, 'closeopen', 'disk', 10);
% t4 = imfill(t3, 'holes');
% t5 = connComp2(t3,1,1);
%
% mask = t5;
%---------------------------------------------------------------



%---------------------------------------------------------------
% t = im(:,:,1)>im(:,:,3);
% t2 = morf(t, 'openclose', 'disk', 10);
% t3 = connComp2(t2,1,1);
%
%
% mask = t3;
%---------------------------------------------------------------





%---------------------------------------------------------------
% t = im > thres;
% t2 = t; %t2 = imfill(t, 'holes');
% %t2 = connComp2(t,1,1);
% %eliminamo componenti connessi troppo piccoli
% bb = regionprops(t2);
% L = bwlabel(t2);
% for g = 1 : numel(bb)
%     area = bb(g).Area;
%     if area < 100
%         ii =  find(L == g);
%         t2(ii) = 0;
%     elseif area >  100000
%         ii =  find(L == g);
%         t2(ii) = 0;
%     end
% end,
%
% mask = t2;
%---------------------------------------------------------------











% %---------------------------------------------------------------
% im = medfilt2(im,[30 30]);
% 
% 
% areaTminus1 = -1;
% areaTminus2 = -1;
% %for sizeSe = 60 : 20 : 200
% for sizeSe = 100
%     
%     %I1 = imadjust(im);
%     I2 = imtophat(im,strel('disk',sizeSe));
%     [level, em] = graythresh(I2);
%     bw = im2bw(I2,level);
%     bw2 = bwareaopen(bw, 50);
%     
%     mask = bw2;
%     
%     stats = regionprops(mask, 'all');
%     areaT = 0;
%     for g = 1 : numel(stats),
%         areaT = areaT + stats(g).Area;
%     end,
%     
%     if areaT >= areaTminus1 && areaTminus1 >= areaTminus2
%         areaTminus2 = areaTminus1;
%         areaTminus1 = areaT;
%     else
%         mask = morf(mask, 'close', 'diamond', 5);
%         break;
%     end
%     
% end,
% 
% %eliminamo componenti connessi troppo piccoli
% bb = regionprops(mask);
% L = bwlabel(mask);
% for g = 1 : numel(bb)
%     area = bb(g).Area;
%     if area < 5000
%        mask(L == g) = 0;
%     end
% end,
% 
% %---------------------------------------------------------------















% %---------------------------------------------------------------
% sizeMedfilt = 10;
% 
% tt = medfilt2(img,[sizeMedfilt sizeMedfilt]);
% 
% %[t, th] = edge(tt,'sobel',0.010); th,
% [t, th] = edge(tt,'sobel'); th,
% t2 = morf(t,'close','diamond', 20);
% t2 = imfill(t2,'holes');
% t3 = morf(t2,'open','diamond',5);
% t4 = morf(t3,'close','square',30);
% 
% mask = t4;
% 
% %eliminamo componenti connessi troppo piccoli
% bb = regionprops(mask);
% L = bwlabel(mask);
% for g = 1 : numel(bb)
%     area = bb(g).Area;
%     if area < 5000
%        mask(L == g) = 0;
%     end
% end,

% %---------------------------------------------------------------











% 
% 
% 
% % %---------------------------------------------------------------
% sizeSe = 100;
% im = imtophat(im,strel('disk',sizeSe));
% 
% 
% tone = im(:,:,1) > rgb2gray(im) & im(:,:,3) < rgb2gray(im);
% %tbis = imgray > 200;
% tbis = im(:,:,1) > 60;
% %t = logical(tone + tbis);
% t = tbis;
% 
% t2 = morf(t, 'openclose', 'disk', 2);
% 
% 
% 
% % %eliminamo componenti connessi troppo piccoli
% bb = regionprops(t2, 'all');
% [L, num] = bwlabel(t2);
% for g = 1 : numel(bb)
%     area = bb(g).Area;
%     if area < 1500
%        t2(L == g) = 0;
%     end
% end,
% 
% t3 = imfill(t2,'holes');
% 
% 
% %edge detector
% te = edge(im(:,:,1), 'sobel');
% te2 = morf(te, 'dilate', 'disk', 3);
% te3 = logical(imfill(te2, 'holes'));
% 
% te4 = morf(te3, 'openclose', 'disk', 1);
% 
% % %eliminamo componenti connessi troppo piccoli
% bb = regionprops(te4, 'all');
% [L, num] = bwlabel(te4);
% for g = 1 : numel(bb)
%     area = bb(g).Area;
%     if area < 1500
%        te4(L == g) = 0;
%     end
% end,
% 
% 
% mask = logical(t3 .* te4);
% 
% mask(920:end,:) = 0;
% % % %---------------------------------------------------------------
% 
% 










%---------------------------------------------------------------
% sizeSe = 100;
% imth = imtophat(im,strel('disk',sizeSe));
% 
% %[thr, em] = graythresh(imth(:,:,1)); %thr
% thr = 50;
% %[thg, em] = graythresh(imth(:,:,2)); %thg,
% %[thb, em] = graythresh(imth(:,:,3)); %thb,
% 
% %tone = imth(:,:,1) > thr*255 & imth(:,:,2) > thg*255 & imth(:,:,3) > thb*255;
% tone = imth(:,:,1) > thr;
% tbis = imgray > 200;
% t = logical(tone + tbis);
% 
% % %eliminamo componenti connessi troppo piccoli
% bb = regionprops(t, 'all');
% [L, num] = bwlabel(t);
% for g = 1 : numel(bb)
%     area = bb(g).Area;
%     if area < 1500
%        t(L == g) = 0;
%     end
% end,
% 
% t2 = imfill(t,'holes');
% 
% mask = t2;
% 
% mask(920:end,:) = 0;
% %---------------------------------------------------------------














% %---------------------------------------------------------------

tone = im(:,:,1) > rgb2gray(im) & im(:,:,3) < rgb2gray(im);
tbis = rgb2gray(im) > 200;
t = logical(tone + tbis);

t2 = morf(t, 'openclose', 'disk', 5);

% % %eliminamo componenti connessi troppo piccoli
% bb = regionprops(t2, 'all');
% [L, num] = bwlabel(t2);
% for g = 1 : numel(bb)
%     area = bb(g).Area;
%     if area < 1000
%     %if area < 10
%        t2(L == g) = 0;
%     end
% end,

t2 = connComp2(t2, 1, 1);

t3 = imfill(t2,'holes');

mask = t3;

mask(920:end,:) = 0;
% % %---------------------------------------------------------------



