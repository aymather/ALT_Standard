function ALTS_outro(settings,trialseq,data)

% Outro
Screen('TextSize', settings.screen.outwindow, settings.layout.size.intro);
DrawFormattedText(settings.screen.outwindow, 'Thank You Very Much For Your Participation!', 'center', 'center', settings.layout.color.text);
Screen('Flip', settings.screen.outwindow); %update screen
WaitSecs(.2); KbWait(-1);

% Clean Up
Screen('CloseAll');
PsychPortAudio('Close');
save(fullfile(settings.files.outfolder,settings.files.outfile), 'trialseq', 'settings', 'data');
ShowCursor; Priority(0); ListenChar(0);

clear;clc

% All Done :)