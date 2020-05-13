clc
close all
clear all



dirDatiRecenti = { ...
    'G:\Angelo\2015-07-30 SW Acquisizione caduta_TIS_v5_DEMO\Dati_recenti_DEMO\001\Features_size', ...
	'G:\Angelo\2015-07-30 SW Acquisizione caduta_TIS_v5_DEMO\Dati_recenti_DEMO\003\Features_size', ...
	'G:\Angelo\2015-07-30 SW Acquisizione caduta_TIS_v5_DEMO\Dati_recenti_DEMO\005\Features_size', ...
    };


features_LengthT = [];
features_WidthT = [];
labelLengthT = [];
labelWidthT = [];
for dd = 1 : numel(dirDatiRecenti)
    
    if dd == 1
        labelLength = 119;
        labelWidth = 20;
    end
    if dd == 2
        labelLength = 120;
        labelWidth = 21;
    end
    if dd == 3
        labelLength = 120;
        labelWidth = 16;
    end
    
    filesMat = dir([dirDatiRecenti{dd} '\*.mat']);
    
    for g = 1 : numel(filesMat)
        load([dirDatiRecenti{dd} '\' filesMat(g).name]);
        features_LengthT = [features_LengthT; features_length];
        features_WidthT = [features_WidthT; features_width];
        labelLengthT = [labelLengthT; labelLength];
        labelWidthT = [labelWidthT; labelWidth];
    end %for g
    
    
end %for dd

					
					
	
save('features_LengthT.mat', 'features_LengthT');
save('features_WidthT.mat', 'features_WidthT');
save('labelLengthT.mat', 'labelLengthT');
save('labelWidthT.mat', 'labelWidthT');
