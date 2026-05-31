function [vid, src] = setCamTIS(id_cam, frames_per_trigger, gain, exposure)


%CAMERE TIS
%%%%%%%%%
vid = videoinput('tisimaq_r2013', id_cam, 'RGB32 (1600x1200)');
%%%%%%%%%


vid.FramesPerTrigger = frames_per_trigger;

src = getselectedsource(vid);
%quante immagini salvare ad ogni trigger
%framerate %spazio prima del numero se < 10
src.FrameRate = ' 3.75';
%exposure
src.ExposureAuto = 'off';
src.Exposure = exposure;


%gain
src.Gain = gain;
src.GainAuto = 'off';


%altri parametri (default)
src.ColorEnhancement = 'Disable';

%strobe
if id_cam == 1
    src.StrobeDuration = 100;
    src.Strobe = 'Enable';
    src.StrobeMode = 'exposure';
    src.StrobePolarity = 'High';
    src.StrobeDelay = 0;
end

if id_cam == 2
    src.StrobeDuration = 100;
    src.Strobe = 'Disable';
    src.StrobeMode = 'exposure';
    src.StrobePolarity = 'High';
    src.StrobeDelay = 0;
end

%trigger
if id_cam == 1
    src.Trigger = 'Enable'; %hardwaretrigger
    src.TriggerDelay = 4;
    src.TriggerPolarity = 'High';
    src.TriggerSoftwareTrigger = 'Ready';
end

if id_cam == 2
    src.Trigger = 'Enable'; %hardwaretrigger
    src.TriggerDelay = 4;
    src.TriggerPolarity = 'Low';
    src.TriggerSoftwareTrigger = 'Ready';
end


%src.WhiteBalanceAuto = 'Off';
src.WhiteBalanceBlue = 73;
src.WhiteBalanceGreen = 64;
src.WhiteBalanceRed = 118;
src.WhiteBalanceTemperaturePreset = 'Daylight';
src.WhiteBalanceOnePush = 'Ready';
%src.WhiteBalanceWhiteBalanceMode = 'Grey World';

src.Brightness = 0;
src.Contrast = 0;
src.Denoise = 0;
src.GPIOGPIN = 0;
src.GPIOGPOut = 1;
src.GPIORead = 'Ready';
src.GPIOWrite = 'Ready';
src.Gamma = 100;
src.Highlightreduction = 'Disable';
src.Hue = 0;
src.NamedPropertySetsLoadset = 'Ready';
src.Saturation = 64;
src.Sharpness = 0;

% if id_cam == 1
%    triggerconfig(vid, 'manual');
% end
% 
% if id_cam == 2
   triggerconfig(vid, 'immediate');
% end
    