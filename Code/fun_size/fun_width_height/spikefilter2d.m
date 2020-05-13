function [matchL_ref2d, matchR_ref2d] = spikefilter2d(matchL, matchR, nPiall, nstd)
%point cloud: CCCLr CCCLm


fprintf(1,'2D Spike filtering...\n');

matchL_ref2d = matchL;
matchR_ref2d = matchR;



euclD = NaN .* ones(size(matchL_ref2d,1),1);
for dd=1:size(matchL_ref2d,1),
euclD(dd) = eudistance(matchL_ref2d(dd,:)',matchR_ref2d(dd,:)');
end,


%Controllo outlier più grossi
if(1),


for piall=1:nPiall, 

meuclD = mean(euclD);
stdeuclD = std(euclD);


iz = find(euclD > meuclD + nstd*stdeuclD | euclD < meuclD - nstd*stdeuclD);
matchL_ref2d(iz,:) = [];
matchR_ref2d(iz,:) = [];
euclD(iz) = [];

end, %end for piall

end, %end if









%Spike filter

for fff=1:1, %number of iterations

areas = 5; %area for mean and std computation
thres = 5; %threshold
thresd = 20; %threshold for distance (helps consider only neighbouring points)
              

[matchL_ref2d isort] = sortrows(matchL_ref2d,[1 2]);
matchR_ref2d = matchR_ref2d(isort,:);
euclD = euclD(isort);

indexrem1 = [];
%eliminamo spike
count = numel(euclD);
ss = 1+floor(areas/2);
while ss <= count - areas;

if  abs(matchL_ref2d(ss,2) - matchL_ref2d(ss+floor(areas/2),2)) > thresd,
ss = ss + 1;
continue;
end,

meanloc = mean([euclD(ss-floor(areas)/2:ss-1)' euclD(ss+1:ss+floor(areas/2))']);
stdloc = std([euclD(ss-floor(areas/2):ss-1)' euclD(ss+1:ss+floor(areas/2))']) / 2;
if abs(euclD(ss) - meanloc) > (thres + stdloc),
%indexrem1 = [indexrem1 ss];

matchL_ref2d(ss,1) = mean([matchL_ref2d(ss-areas/2:ss-1,1)' matchL_ref2d(ss+1:ss+areas/2,1)']);
matchL_ref2d(ss,2) = mean([matchL_ref2d(ss-areas/2:ss-1,2)' matchL_ref2d(ss+1:ss+areas/2,2)']);
matchR_ref2d(ss,1) = mean([matchR_ref2d(ss-areas/2:ss-1,1)' matchR_ref2d(ss+1:ss+areas/2,1)']);
matchR_ref2d(ss,2) = mean([matchR_ref2d(ss-areas/2:ss-1,2)' matchR_ref2d(ss+1:ss+areas/2,2)']);
euclD(ss) = mean([euclD(ss-areas/2:ss-1)' euclD(ss+1:ss+areas/2)']);

end, %end if
count = numel(euclD);
ss = ss + 1;
end, %end for



%CCCLrf(indexrem1,:) = [];
%CCCLmf(indexrem1,:) = [];
%euclD(indexrem1) = [];



[matchL_ref2d isort] = sortrows(matchL_ref2d,[2 1]);
matchR_ref2d = matchR_ref2d(isort,:);
euclD = euclD(isort);



indexrem2 = [];
count = numel(euclD);
ss = 1+floor(areas/2);
while ss <= count - areas;

if  abs(matchL_ref2d(ss,2) - matchL_ref2d(ss+floor(areas/2),2)) > thresd,
ss = ss + 1;
continue;
end,

meanloc = mean([euclD(ss-floor(areas)/2:ss-1)' euclD(ss+1:ss+floor(areas/2))']);
stdloc = std([euclD(ss-floor(areas/2):ss-1)' euclD(ss+1:ss+floor(areas/2))']) / 2;
if abs(euclD(ss) - meanloc) > (thres + stdloc),
%indexrem2 = [indexrem2 ss];

matchL_ref2d(ss,1) = mean([matchL_ref2d(ss-areas/2:ss-1,1)' matchL_ref2d(ss+1:ss+areas/2,1)']);
matchL_ref2d(ss,2) = mean([matchL_ref2d(ss-areas/2:ss-1,2)' matchL_ref2d(ss+1:ss+areas/2,2)']);
matchR_ref2d(ss,1) = mean([matchR_ref2d(ss-areas/2:ss-1,1)' matchR_ref2d(ss+1:ss+areas/2,1)']);
matchR_ref2d(ss,2) = mean([matchR_ref2d(ss-areas/2:ss-1,2)' matchR_ref2d(ss+1:ss+areas/2,2)']);
euclD(ss) = mean([euclD(ss-areas/2:ss-1)' euclD(ss+1:ss+areas/2)']);

end, %end if
count = numel(euclD);
ss = ss + 1;
end, %end for




%CCCLrf(indexrem2,:) = [];
%CCCLmf(indexrem2,:) = [];
%euclD(indexrem2) = [];




end, %end for fff





%togliamo i punti in fondo che danno problemi nell'interpolazione di superficie
if(1),
[matchL_ref2d isort] = sortrows(matchL_ref2d,[1 2]);
matchR_ref2d = matchR_ref2d(isort,:);
euclD = euclD(isort);

matchL_ref2d(end-50:end,:) = [];
matchR_ref2d(end-50:end,:) = [];
euclD(end-50:end) = [];


end,





if(0),
figure,
imshow(imAgray), hold on, plot(CCCLrf(:,1),CCCLrf(:,2),'xr','MarkerSize',8,'LineWidth',2);
title('A')
figure,
imshow(imBgray), hold on, plot(CCCLmf(:,1),CCCLmf(:,2),'xr','MarkerSize',8,'LineWidth',2);	
title('B')	
pause
end,









