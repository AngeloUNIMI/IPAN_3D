function [vid, src] = setCamSony(id_cam, frames_per_trigger, gain, exposure)



%CAMERE SONY
%%%%%%%%%%
vid = videoinput('dcam', id_cam, 'F7_RAW8_1280x960');
src = getselectedsource(vid);
%%%%%%%%%%

vid.FramesPerTrigger = frames_per_trigger;

%src.ShutterControl = 'relative';
%src.Shutter = exposure;
%src.ShutterControl = 'absolute';
src.ShutterAbsolute = exposure;
%src.Exposure = exposure;

%src.FrameRate = ' 3.75';

%src.GainMode = 'manual';
src.Gain = gain;

vid.ReturnedColorspace = 'bayer';
vid.BayerSensorAlignment = 'gbrg';

src.AutoExposure = 500;

src.Brightness = 0;

src.FrameTimeout = 30000;

src.Gamma = 0;

src.Hue = 2048;

src.NormalizedBytesPerPacket = 5;

%src.OpticalFilter = 0;

src.Saturation = 256;

%src.Strobe0 = 'off';
src.Strobe0Delay = 0;
src.Strobe0Duration = 0;

src.TriggerDelay = 0;
src.TriggerParameter = 0;
triggerconfig(vid, 'hardware', 'risingEdge', 'externalTrigger');

src.WhiteBalance = [1928 2095];
%src.WhiteBalanceMode = 'manual';



