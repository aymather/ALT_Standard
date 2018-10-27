function settings = ALTS_initialize(data)

% HANDLES
settings.daq = DaqDeviceIndex;
if rand >= .5
    settings.fast_stan = true;
else
    settings.fast_stan = false;
end

% TRIALS
if data.training == 0
    settings.general.nov_v = .1; % visual 10%
    settings.general.nov_a = .1; % auditory 10%
    settings.general.nov_h = .1; % haptic 10%
    settings.general.nogo = 1/3; % nogo 1/3 
    settings.general.go = 2/3; % go 2/3
    settings.general.trials = 60;
    settings.general.blocks = 8;
else
    settings.general.nov_v = 0;
    settings.general.nov_a = 0;
    settings.general.nov_h = 0;
    settings.general.nogo = 1/3;
    settings.general.go = 2/3;
    settings.general.trials = 30;
    settings.general.blocks = 1;
end

% SIZE
settings.layout.size.fixation = 40;
settings.layout.size.offset = 100;
settings.layout.size.intro = 40;
settings.layout.size.diamond = 100;
settings.layout.size.text = 40;
settings.layout.size.blockfeedback = 60;

% COLOR
settings.layout.color.fixation = [255 255 255];
settings.layout.color.intro = [255 255 255];
settings.layout.color.cue = [0 255 0];
settings.layout.color.text = [255 255 255];
settings.layout.color.diamond = [0 255 0];
settings.layout.color.SLOW = [255 0 0];

% DURATIONS
settings.duration.fixation = 1;
settings.duration.cue = .2; % difference between cue ONSET and stimulus ONSET
settings.duration.deadlineadjust = .025;
settings.duration.deadline = .5;
settings.duration.post_deadline = .5;
settings.duration.iti = 1;
settings.duration.delay = .05;
settings.duration.feedback = .5;

% SOUND
settings.sound.srate = 44100;
settings.sound.duration = .2;
InitializePsychSound(1);
settings.sound.audiohandle = PsychPortAudio('Open', [], [], 0, settings.sound.srate, 1);
load(fullfile(fileparts(which('ALTS.m')), 'backend', 'novelsounds.mat'));
settings.sound.novelsounds = novelsounds(randperm(length(novelsounds))); % randomize sounds
asamples = 0:1/settings.sound.srate:settings.sound.duration;
settings.sound.standardsound = sin(2* pi * settings.sound.standardfreq * asamples);

% SCREEN
settings.screen.bg_novel = [0 0 255]; %novel background color
settings.screen.bg_stan = [0 0 0]; %standard background color
screens = Screen('Screens');
settings.screen.screenNumber = max(screens);
[settings.screen.outwindow, settings.screen.outwindowdims] = Screen('OpenWindow', settings.screen.screenNumber, settings.screen.bg_stan);% make screen, black bg
Priority(MaxPriority(settings.screen.outwindow)); % prioritize

% KEYBOARD / MOUSE
HideCursor; ListenChar(2);
KbName('UnifyKeyNames');
KbCheck; WaitSecs(0.1); GetSecs;

% BUTTON MAP
if data.buttons == 1
    settings.general.buttons = {'W','M'};
else
    settings.general.buttons = {'M','W'};
end

% PREP FONTS
Screen('TextFont',settings.screen.outwindow,'Arial'); % arial
Screen('TextStyle', settings.screen.outwindow, 0); % make normal
    
% SAVE INFO
settings.files.infolder = fileparts(which('ALT.m'));
settings.files.outfolder = fullfile(fileparts(which('ALT.m')),'out',filesep);
clocktime = clock; hrs = num2str(clocktime(4)); mins = num2str(clocktime(5));
settings.files.outfile = ['Subject_' num2str(data.nr) '_' date '_' hrs '.' mins 'h.mat'];