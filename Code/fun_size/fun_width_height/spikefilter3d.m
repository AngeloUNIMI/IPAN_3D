function [matchL_ref3d, matchR_ref3d, XL, YL, ZL, dT] = spikefilter3d(matchL, matchR, XLu, YLu, ZLu, nNeigh3d)

%input:
%CCCLr: N x 2	2D matched points left image Unfiltered
%CCCLm: N x 2	2D matched points right image Unfiltered
%XLu: 1 x N		3D X coordinates Unfiltered
%YLu: 1 x N		3D Y coordinates Unfiltered
%ZLu: 1 x N		3D Z coordinates Unfiltered

% nNeigh3d = Number of neighbours the points must have

%output:
%CCCLrf: N x 2	2D matched points left image Filtered
%CCCLmf: N x 2	2D matched points right image Filtered
%XL: 1 x N		3D X coordinates Filtered
%YL: 1 x N		3D Y coordinates Filtered
%ZL: 1 x N		3D Z coordinates Filtered


mult = 2;
%mult = 1.5;
%mult = 1.1;

XL = XLu;
YL = YLu;
ZL = ZLu;

%---------------------------------------------PRIMO GIRO
%calcolo distanza minima e media
dT = [];
for d1=1:numel(XL)-1,
    t = eudistance([XL(d1) YL(d1) ZL(d1)]',[XL(d1+1) YL(d1+1) ZL(d1+1)]');
    dT = [dT t];
end,
dTsort = sort(dT);
dT = dTsort(51:end);
minddd = min(dT);
meanddd = mean(dT);


%soglia manuale distanza tra i punti 3d
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
minddd = 1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


for giri=1:1,
    
    %eliminiamo
    indexrem = [];
    
    %while 1,
    
    for ddd=1:numel(XL),
        countt = 0;
        for eee=ddd+1:numel(XL),
            if ddd == eee,
                continue;
            end,
            t = eudistance([XL(ddd) YL(ddd) ZL(ddd)]',[XL(eee) YL(eee) ZL(eee)]');
            if (t <= mult*minddd), countt = countt+1; end,
        end,
        if countt < nNeigh3d, indexrem = [indexrem ddd]; end,
        
        if (mod(ddd,100) == 0),
            %fprintf(1,'%d ',ddd);
        end,
        
        if (mod(ddd,1000) == 0),
            %fprintf(1,'%d\n',ddd);
        end,
        
    end,
    
    %if (numel(indexrem)/numel(XL)) > (9/10)
    %    mult = mult * 2;
    %    fprintf(1,'\n',ddd);
    %    continue;
    %else,
    
    matchL_ref3d = matchL;
    matchR_ref3d = matchR;
    
    XL(indexrem) = [];
    YL(indexrem) = [];
    ZL(indexrem) = [];
    
    matchL_ref3d(indexrem,:) = [];
    matchR_ref3d(indexrem,:) = [];
    %end,
    
    
    %end,
    
    %fprintf(1,'\n',ddd);
    
end,



