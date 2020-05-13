clc
clear variables
close all force
%warning('off')
addpath('./util');
addpath('./general');
addpath('./nn');
addpath('./fun_size');
addpath('./fun_size/fun_thickness');
addpath('./fun_size/fun_width_height');
%imaqregister('C:\Program Files (x86)\TIS IMAQ for MATLAB R2013b\x64\TISImaq_R2013.dll');

pause on
log = 1;


%PARAMETRI
%numero telecamere
fidnumcams = fopen('../numcams.txt');
numcams = fscanf(fidnumcams, '%f', 1);
fclose(fidnumcams);
%tempo da aspettare
time_wait = 2;
%tempo da aspettare
time_wait_short = 0.1;
%tempo da aspettare per controllare i lock
time_wait_lock = 0.1;
%directory di salvataggio immagini
dirDatiRecenti = '../Dati_recenti_DEMO/';
%directory di salvataggio immagini storici (es. una ogni 20 minuti)
dirDatiStorici = '../Dati_storici_DEMO/';
%directory temporanea
dirWork = './work_dir/';
%nome file con l'error flag passato dall'orientamento
fileErrorFlagName = './work_dir/error_flag.dat';
%nomefile che indica se ho scritto i parametri per l'orientamento
fileFlagName = './work_dir/file_flag.dat';
%nomefile con i parametri per size
fileParSizeName = './work_dir/fileParSize.dat';
%nomefile con i parametri per thickness
fileParThicknessName = './work_dir/fileParThickness.dat';
%directory con i dati di calibrazione
dirCalib = '..\calib_ren\';

formatDirDay = 'yyyy-mm-dd HH'; %datestr
formatDirDayMinSec = 'yyyy-mm-dd HH-MM-SS'; %datestr
formatDirDay2 = 'yyyy-MM-dd HH'; %datetime
formatDirDayMinSec2 = 'yyyy-MM-dd HH-mm-SS'; %datestr

%file che indica l'inizio di una scrittura burst
file_burst_started = './work_dir/lock_burst_start.dat';
%file che indica la fine di una scrittura burst
file_burst_ended = './work_dir/lock_burst.dat';
%file che indica la fine di del calcolo del size burst
file_size_burst = './work_dir/lock_size_burst.dat';



%lancio altri scripts
% system(  'matlab -nosplash -nodesktop -minimize -r "run(''.\IPAN_caduta_plot_storico.p'')"   &'  );


%aspettiamo che la cattura inizializzi
pause(time_wait);

%leggo flag scrittura file
writeFlag = 0;
while writeFlag == 0
    fileFlag = fopen(fileFlagName, 'r');
    if fileFlag == -1
        continue
    end
    writeFlag = fscanf(fileFlag, '%f', 1);
    fclose(fileFlag);
    pause(time_wait);
end

%leggo parametri size
fileParSize = fopen(fileParSizeName, 'r');
desired_mean_major_axis = fscanf(fileParSize, '%f', 1);
desired_mean_minor_axis = fscanf(fileParSize, '%f', 1);
toll_mean_major_axis = fscanf(fileParSize, '%f', 1);
toll_mean_minor_axis = fscanf(fileParSize, '%f', 1);
num_img_burst = fscanf(fileParSize, '%f', 1);
fclose(fileParSize);

%leggo parametri thickness
fileParThickness = fopen(fileParThicknessName, 'r');
desired_mean_thickness = fscanf(fileParThickness, '%f', 1);
toll_mean_thickness = fscanf(fileParThickness, '%f', 1);
num_img_burst = fscanf(fileParThickness, '%f', 1);
fclose(fileParThickness);


%flag situazione non corretta
errorFlag = 0;

%importiamo time before reset
fid_time_before_reset = fopen('./work_dir/time_before_reset.dat', 'r');
time_before_reset_s = fscanf(fid_time_before_reset, '%f');
fclose(fid_time_before_reset);


%CALCOLO DIMENSIONI VISUALIZZAZIONE
screen_size = get(0,'screensize');
height_plot = screen_size(4)/2-50;



%CREIAMO GLI HANDLE DELLE FIGURE
%per le figure acquisite
for id_cam = 1 : numcams
    handle_im{id_cam} = figure('CloseRequestFcn', '', 'Toolbar','none', 'Menubar', 'none', 'NumberTitle','Off', 'Name', ['CAM ' num2str(id_cam') ' Time: ' datestr(now)]);
    ax_im{id_cam} = axes;
    %creiamo controlli testuali per mostrare gain e shutter e timestamp
    
    %hTextLabel_Shutter = uicontrol(handle_im{id_cam}, 'style', 'text', 'String', ['Sh. ' sprintf('%.2f',src{id_cam}.Exposure) 's'], 'Units', 'normalized', 'Position', [0.15 -.04 .12 .08]);
    %hTextLabel_Gain = uicontrol(handle_im{id_cam}, 'style', 'text', 'String', ['G. ' num2str(src{id_cam}.Gain)], 'Units', 'normalized', 'Position', [0.3 -.04 .12 .08]);
    %hTextLabel_Framerate = uicontrol(handle_im{id_cam}, 'style', 'text', 'String', [num2str(src{id_cam}.FrameRate) ' fps'], 'Units', 'normalized', 'Position', [0.45 -.04 .12 .08]);
    
end
%impostiamo posizione finestra dell'immagine acquisita
set(handle_im{1},'Position',[0 (screen_size(4)-height_plot-35) screen_size(3)/3 height_plot]);
if numcams == 2
    set(handle_im{2},'Position',[0 (screen_size(4)-(height_plot+35)*2-0) screen_size(3)/3 height_plot]);
end

%sempre visibili
for id_cam = 1 : numcams
    %WinOnTop(handle_im{id_cam}, true);
end



%per fargli ciclare su tutti
%%%%%%%%%%%%%%%%%%%
num_img_burst = 72;
%%%%%%%%%%%%%%%%%%%







% switch che conta quante volte sta aspettando immagini
%stopped = 0;

%timestamp ultima volta che ha visto nuovi file
last_new_files = datetime('now', 'Format','yyyy-MM-dd HH-mm-SS');

%timer_reset
id_timer_reset = tic;



%-----------------------------------------CARICAMENTO DATI DI CALIBRAZIONE
cF = pwd;
cd(dirCalib)
infoDataset
cd CalibMatlabNew
load('Homos.mat')
load('stereoParams.mat');
cd(cF)
%--------------------------------------------------------------------------


%CICLO PRINCIPALE ACQUISIZIONE/ELABORAZIONE/PLOT RISULTATI
while true
    
    
    timer_reset = toc(id_timer_reset);
    %if timer_reset > 86400
%     if timer_reset > time_before_reset_s && exist(file_burst_started, 'file') ~= 2 && exist(file_burst_ended, 'file') ~= 2 ...
%             && exist(file_size_burst, 'file') ~= 2 
%         system('%UserProfile%\Desktop\RIAVVIA_SW_Caduta.bat')
%     end
    
    %tic
    
    %creo i timestamp;
    now = datetime('now', 'Format','yyyy-MM-dd HH-mm-SS');
    
    
    
    %controlliamo che capture abbia finito la scrittura burst
    %se non esiste burst, oppure esiste burst_segm, saltiamo
    %-> deve esistere burst E non esistere burst_segm
%     if exist(file_burst_ended, 'file') ~= 2 || exist(file_size_burst, 'file') == 2
%         %fprintf(1, 'In attesa...\n');
%         %controlliamo quanto tempo è passato
%         diff_in_seconds_last_new_files = etime(datevec(now), datevec(last_new_files) );
%         diff_in_minutes_last_new_files = floor(diff_in_seconds_last_new_files / 60 );
%         %se passato troppo tempo (es + di 4 h) riavviamo
%         if diff_in_minutes_last_new_files > 240
%             system('%UserProfile%\Desktop\RIAVVIA_SW_Caduta.bat')
%         else
%             pause(time_wait);
%             continue
%         end
%     end %end while exist
    
    
    
    %se ci sono nuovi file, aggiorniamo timestamp ultima volta che ha visto nuovi file
    last_new_files = datetime('now', 'Format','yyyy-MM-dd HH-mm-SS');
    %fprintf(1, ['Nuovi file: ' datestr(now, formatDirDayMinSec) '\n']);
    
    
    %azzeriamo conteggio file letti
    clear ind_burst
    ind_burst = zeros(numcams, 1);
    
    
    %estraiamo la directory del giorno corrente
    dirs = list_only_subfolders(dirDatiRecenti);
    
    clear filename
    %partiamo dalle più vecchie
    for dd = numel(dirs) : -1 : 1
        
        for id_cam = 1 : numcams
            dirDay{id_cam} = [dirDatiRecenti dirs{dd} '/CAM ' num2str(id_cam) '/'];
        end %end for id_cam
        
        %directory di salvataggio file risultato segm
        for id_cam = 1 : numcams
            dirDatiRecentiSizeDay{id_cam} = [dirDay{id_cam} 'Size/'];
        end %end for id_cam
        
        
        %lettura immagini
        for id_cam = 1 : numcams
            files{id_cam} = dir([dirDay{id_cam} '* ' num2str(id_cam) '.tif']);
            
            %se non ci sono file usciamo
            if numel(files{id_cam}) == 0
                break;
            end
            
            %cicliamo sui file nella directory, dalla più vecchia
            for ff = numel(files{id_cam}) : -1 : 1
                
                files_s = files{id_cam};
                filename{ind_burst(id_cam)+1, id_cam} = [dirDay{id_cam} files_s(ff).name];
                ind_burst(id_cam) = ind_burst(id_cam) + 1;
                
                %quando arriviamo al numero di immagini burst smettiamo di leggere
                if ind_burst(id_cam) >= num_img_burst
                    break
                end
                
            end % for ff = 1 : numel(files{id_cam})
            
        end %for id_cam = 1 : numcams,
        
        %quando arriviamo al numero di immagini burst, per tutte le telecamere, smettiamo di leggere
        if numel(find(ind_burst >= num_img_burst)) == numcams
            break
        end
        
        %se non ci sono file saltiamo la directory
        if numel(files{id_cam}) == 0
            continue
        end
        
    end % for dd = 1 : numel(dirs)
    
    
    %pause
    
    
    
    
    
    %leggiamo immagine da disco
    %ciclo su immagini burst
    clear imgs
    %allocazione statica imgs
    t_img = imread(filename{1, 1});
    imgs = cell(ind_burst(1), numcams);
    for jj = 1 : ind_burst(1)
        for id_cam = 1 : numcams
            imgs{jj, id_cam} = zeros(size(t_img));
        end %for id_cam = 1 : numcams,
    end % for jj = 1 : ind_burst
    
    for jj = 1 : ind_burst(1)
        
        for id_cam = 1 : numcams
            
            %leggiamo se è presente lock
            fileErrorImgLockName = ['./work_dir/img_' num2str(id_cam) '.lock'];
            
            %finchè esiste aspetto
            while exist(fileErrorImgLockName, 'file') == 2
                pause(time_wait_lock);
            end
            
            %se il file non esiste la risorsa è libera
            imgs{jj, id_cam} = imread(filename{jj, id_cam});
            
        end %for id_cam = 1 : numcams,
        
    end % for jj = 1 : ind_burst
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %whos
    %ELABORAZIONE
    
    
    
    for jj = 1 : ind_burst(1)
    %for jj = 6
        
        %variabile che uso per fargli saltare questo loop da dentro
        salto = 0;
        
        %visualizzo
        for id_cam = 1 : numcams
            set(0, 'currentfigure', handle_im{id_cam});  %# for figures
            imshow(imgs{jj, id_cam}, 'Parent', ax_im{id_cam}, 'Border', 'tight');
            set(handle_im{id_cam}, 'Name', ['CAM: ' num2str(id_cam) ' - ' datestr(now)] );
        end %for id_cam
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %impostiamo posizione finestra dell'immagine acquisita
        set(handle_im{1},'Position',[0 (screen_size(4)-height_plot-35) screen_size(3)/3 height_plot]);
        if numcams == 2
            set(handle_im{2},'Position',[0 (screen_size(4)-(height_plot+35)*2-0) screen_size(3)/3 height_plot]);
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        
        
        %tic
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %CALCOLO
        fprintf(1, ['\nProcessing: ' filename{jj, 1} '\n']);
        
        
        %calcola size
        if size(imgs, 2) == 1
            fprintf(1, 'NUMCAMS == 2 - CONTROLLARE I PARAMETRI DEL SOFTWARE!\r\n');
            return
        end %if size(imgs, 2) == 1
          
        clear majAxis minAxis thickness maskboth
        [majAxis, minAxis, thickness, maskboth, retvalue, features_thickness, features_length, features_width] = ...
            calcola_size(imgs{jj, 1}, imgs{jj, 2}, stereoParams, H4, screen_size, height_plot);

        %correzione non neurale
        %%%%%%%%%%%%%%%%%%%%%%%%%
        %majAxis = majAxis / 1.25;
        %minAxis = minAxis / 1.75;
        %%%%%%%%%%%%%%%%%%%%%%%%%
        
%         close all
%         figure,imshow(imgs{jj, 1})
%         figure,imshow(imgs{jj, 2})
%         figure,imshow(maskboth{1})
%         figure,imshow(maskboth{2})
%         pause
               
        %controlli su numel(output) > 0
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %SCRITTURA SU FILE RISULTATI
        clear filenametxt_fin_size
        
        %mask
        %calcoliamo il nome del file
        for id_cam = 1 : numcams
            t = filename{jj, 1};
            [C, matches] = strsplit(t, '/');
            %filenamep1 = [C{1} '/' C{2} '/' C{3} '/' C{4} '/'];
            filenamep1 = [C{1} '/' C{2} '/' C{3} '/'];
            filenamep2 = 'Mask/'; %%%%%
            t2 = C{5};
            %filenamep3 = t2(1:end-10);
            filenamep3 = t2(1:end-6);
            if id_cam == 1, filenamep4 = '_MaskA.jpg'; end
            if id_cam == 2, filenamep4 = '_MaskB.jpg'; end
            filenametxt_fin_size{id_cam} = [filenamep1 filenamep2 filenamep3 filenamep4];
            saveMask(imgs{jj, id_cam}, maskboth{id_cam}, filenametxt_fin_size{id_cam});
        end %for id_cam = 1 : numcams
        
        
        %size
        if numel(majAxis) > 0
            %calcoliamo il nome del file
            t = filename{jj, 1};
            [C, matches] = strsplit(t, '/');
            %filenamep1 = [C{1} '/' C{2} '/' C{3} '/' C{4} '/'];
            filenamep1 = [C{1} '/' C{2} '/' C{3} '/'];
            filenamep2 = 'Size/'; %%%%%
            t2 = C{5};
            %filenamep3 = t2(1:end-10);
            filenamep3 = t2(1:end-6);
            filenamep4 = '_Size.txt';
            filenametxt_fin_size = [filenamep1 filenamep2 filenamep3 filenamep4];
            %salviamo features
            filenamep2f = 'Features_size/'; %%%%%
            filenamep4f = '_features_size.mat';
            save([filenamep1 filenamep2f filenamep3 filenamep4f], 'features_length', 'features_width');
            
            %%%correzione neurale
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            majAxis = nn_length(features_length);
            minAxis = nn_width(features_width);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            fidtxt = fopen(filenametxt_fin_size, 'w');
            if fidtxt ~= -1
                fprintf(fidtxt, 'Mean Major Axis:\r\n%f\r\n', majAxis);
                fprintf(fidtxt, 'Mean Minor Axis:\r\n%f\r\n', minAxis);
                fclose(fidtxt);
            end %end if fidtxt ~= -1
            if log == 1
                fprintf(1, 'Mean Major Axis:\n%f\n', majAxis);
                fprintf(1, 'Mean Minor Axis:\n%f\n', minAxis);
            end %end if log
            %%%%%
            
        else %if numel(majAxis) > 0   
            if log == 1
                fprintf(1, 'Impossibile calcolare lunghezza e larghezza\n');
            end %end if log     
        end %if numel(majAxis) > 0  
        
        
        
        %thickness
        if numel(thickness) > 0
            %calcoliamo il nome del file
            t = filename{jj, 1};
            [C, matches] = strsplit(t, '/');
            %filenamep1 = [C{1} '/' C{2} '/' C{3} '/' C{4} '/'];
            filenamep1 = [C{1} '/' C{2} '/' C{3} '/'];
            filenamep2 = 'Thickness/'; %%%%%
            t2 = C{5};
            %filenamep3 = t2(1:end-10);
            filenamep3 = t2(1:end-6);
            filenamep4 = '_Thickness.txt';
            filenametxt_fin_thickness = [filenamep1 filenamep2 filenamep3 filenamep4];
            %salviamo features
            filenamep2f = 'Features_thickness/'; %%%%%
            filenamep4f = '_features_thickness.mat';
            save([filenamep1 filenamep2f filenamep3 filenamep4f], 'features_thickness');
            
            fidtxt = fopen(filenametxt_fin_thickness, 'w');
            if fidtxt ~= -1
                fprintf(fidtxt, 'Mean thickness:\r\n%f\r\n', thickness);
                fclose(fidtxt);
            end %end if fidtxt ~= -1
            if log == 1
                fprintf(1, 'Mean thickness:\n%f\n', thickness);
            end %end if log

        else %if numel(majAxis) > 0
            if log == 1
                fprintf(1, 'Impossibile calcolare spessore\n');
            end %end if log     
        end %if numel(majAxis) > 0 
        
    
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        
        
%         pause(time_wait_short);
        pause; close all
        
        %toc
    end %end for jj = 1 : ind_burst
    
    
    %quando finisco il burst scrivo file per dire che ho finito
    fid_burst_size = fopen(file_size_burst, 'w');
    fclose(fid_burst_size);
    
    %toc
    %circa 18s per 2 cam
    
    
    
    
    
    
    pause(time_wait_short);
    
end % end ciclo acquisizione for g = 1 : 100





