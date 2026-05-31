function [matchL, matchR, distLT, distRT, ilt, irt] = match_punti_silhouette(im1gray, maskA, im2gray, maskB, plotta, minYA, minYB)




%--------------------------------------------------------ESTRAZIONE PUNTI
%fprintf(1,'Estrazione punti.....\n');
%[il jl] = find(maskA == 1);
[il, jl] = find(edge(maskA) == 1);
CL = [jl il];
[CLtheta, CLrho] = cart2pol(CL(:,1), CL(:,2));




[il, jl] = find(edge(maskB) == 1);
CR = [jl il];
[CRtheta, CRrho] = cart2pol(CR(:,1), CR(:,2));


%le immagini sono rettificate, allineiamo
% minYA = min(CL(:,2));
CL(:,2) = CL(:,2) - minYA;
% minYB = min(CR(:,2));
CR(:,2) = CR(:,2) - minYB;


if(0),
    hm2 = figure; imshow(imA),
    hold on, scatter(CL(:,1),CL(:,2))
    hm3 = figure; imshow(imB),
    hold on, scatter(CR(:,1),CR(:,2))
    pause(1)
end,








%---------------------------------MATCHING POINTS
%fprintf(1,'Matching dei punti.....\n');

matchL = [];
matchR = [];

%immagine A
%punto in basso centrale
%minY = min(CL(:,2));

maxDiffL = -1;
minDiffL = 1e6;
distLT = [];
distRT = [];
switch1 = 0;

%ciclo su Y
for jj = min(CL(:,2)) : max(CL(:,2))
    indl = find(CL(:,2) == jj);
    ppl = CL(indl,:);
    
    
    indr = find(CR(:,2) == jj);
    ppr = CR(indr,:);
    
    if numel(ppl) > 0 && numel(ppr) > 0
        
        distL = pdist([ppl(1,:); ppl(end,:)], 'euclidean');
        distR = pdist([ppr(1,:); ppr(end,:)], 'euclidean');
        diffL = abs(distL - distR);
        
        distLT = [distLT distL];
        distRT = [distRT distR];
        
        if diffL > maxDiffL,
            maxDiffL = diffL;
        end,
        if diffL < minDiffL,
            minDiffL = diffL;
        end,
        
    end,
    
    if numel(indl) == numel(indr)
        
        
        %                 if switch1 == 0,
        %                     pp1_start = ppl(1,:);
        %                     pp2_start = ppr(1,:);
        %                     switch1 = 1;
        %                 end,
        
        %pp1_end = ppl(1,:);
        %pp2_end = ppr(1,:);
        
        %distY = pdist([ppl(1,:); ppl(end,:)], 'euclidean');
        
        %                 if distY > maxDist
        %                     maxDist = distY;
        %                     pp1_m = [ppl(1,:); ppl(end,:)];
        %                     pp2_m = [ppr(1,:); ppr(end,:)];
        %                 end,
        
        
        %             figure(3),
        %             subplot(1,2,1)
        %             imshow(imA), hold on,
        %             plot(ppl(:,1), ppl(:,2), 'gx');
        %             subplot(1,2,2)
        %             imshow(imB), hold on,
        %             plot(ppr(:,1), ppr(:,2), 'gx');
        %             pause,
        
        matchL = [matchL; ppl];
        matchR = [matchR; ppr];
        
    end,
    
    
end,




ilt = find(distLT < 10);
irt = find(distRT < 10);





%invertiamo allineamento
matchL(:,2) = matchL(:,2) + minYA;
matchR(:,2) = matchR(:,2) + minYB;







if 0,
    figure,
    imshow(im1gray), hold on, plot(matchL(:,1),matchL(:,2),'xr','MarkerSize',8,'LineWidth',2);
    title('Punti Matchati immagine A')
    figure,
    imshow(im2gray), hold on, plot(matchR(:,1),matchR(:,2),'xr','MarkerSize',8,'LineWidth',2);
    title('Punti Matchati immagine B')
    pause
end,


%calcolo plot figo
if plotta
    offset1 = 50;
    minxl = min(matchL(:,1));
    minyl = min(matchL(:,2));
    maxxl = max(matchL(:,1));
    maxyl = max(matchL(:,2));
    im1plot = im1gray(minyl - offset1 : maxyl + offset1, minxl - offset1 : maxxl + offset1 + offset1);
    im2plot = im2gray(minyl - offset1 : maxyl + offset1, minxl - offset1 : maxxl + offset1 + offset1);
    
    stac = 10;
    implot = [im1plot ones(size(im1plot,1), stac) im2plot];
    
    removed1x = minxl - offset1;
    removed1y = minyl - offset1;
    removed2x = minxl - offset1;
    removed2y = minyl - offset1;
    
    figure,
    imshow(implot)
    hold on
    for o = 1 : 23 : size(matchL, 1)
    %for o = 1
        point1 = [matchL(o,1)-removed1x matchL(o,2)-removed1y];
        point2 = [matchR(o,1)-removed1x+size(im1plot,2)+stac matchR(o,2)-removed1y];
        plot([point1(1) point2(1)], [point1(2) point2(2)],'rx-', 'MarkerSize', 8, 'LineWidth', 2);
        hold on
    end %end for o

end










%
%     %ciclo su X
%     for ii = min(CL(:,1)) : max(CL(:,1))
%         indl = find(CL(:,1) == ii);
%         ppl = CL(indl,:);
%
%
%         indr = find(CR(:,1) == ii);
%         ppr = CR(indr,:);
%
%         if numel(indl) == numel(indr)
%
%             %             figure(3),
%             %             subplot(1,2,1)
%             %             imshow(imA), hold on,
%             %             plot(ppl(:,1), ppl(:,2), 'gx');
%             %             subplot(1,2,2)
%             %             imshow(imB), hold on,
%             %             plot(ppr(:,1), ppr(:,2), 'gx');
%             %             pause,
%
%             matchL = [matchL; ppl];
%             matchR = [matchR; ppr];
%
%         end,
%
%     end,
%
