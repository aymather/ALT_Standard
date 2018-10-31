% Collect response from handle
%   Jan R Wessel 2016, www.wessellab.org
% THIS WAS EDITED FOR SPECIFIC PURPOSES WITHIN ALT
% Usage:
%   startttime = handle_response(daq, onoff, side, speed)
% Inputs:
%   daq (int) = daq number from DaqDeviceIndex
%   ms (int) = record for how long? (ms)
% Outputs:
%   RT (int) = RT in ms
%   Resp (int) = 1: left handle, 2 = right handle
%   traces (ms x 2 matrix) = raw traces from both handles
% Connectors on DAQ:
%   1: Left handle
%   2: Right handle
% Needs:
%   % DaqAInScanJRW, which is the original PTB function, edited for compatibility with R2015a; where bitcmp doesn't work
function [RT,Resp] = handle_response_ALTS(daq,ms,settings,trialseq,id,it,OW,stim,owd,side)

% settings
DAQoptions.channel = [8 9]; % 8 = single pin A0 (#1), 9 = single pin A1 (#2)
DAQoptions.srate = 1000; % sampling rate 1000 Hz
DAQoptions.range = ones(size(DAQoptions.channel)); % default gain
DAQoptions.count = ms; % actually DAQoptions.srate/1000 * ms; but for 1000Hz this is faster
DAQoptions.ms = ms;

% begin scan
DAQoptions.begin = 1;
DAQoptions.continue = 0;
DAQoptions.end = 0;
DaqAInScanJRW(daq,DAQoptions);

% scan
DAQoptions.continue = 1; DAQoptions.begin = 0;
starttime = GetSecs;

% set flag
vdisplay = false; adisplay = false; hdisplay = false;
voffset = false; hoffset = false;

while GetSecs - starttime < ms/1000
    
    % acquite samples
    DaqAInScanJRW(daq,DAQoptions);
    
    % reset screen
    if GetSecs - starttime >= trialseq(it,id.deadline)
        DrawFormattedText(settings.screen.outwindow, '+', 'center', 'center', settings.screen.bg_stan);
        Screen('Flip', settings.screen.outwindow);
    end
    
    % STIMULUS DISPLAY
    if GetSecs - starttime >= settings.duration.delay

        % if is visual novel
        if ~vdisplay
            
            % flip screen
            Screen('Flip', settings.screen.outwindow);
    
            % RESET SCREEN
            Screen('FillRect', settings.screen.outwindow, settings.screen.bg_stan);
            DrawFormattedText(settings.screen.outwindow, '+', 'center', 'center', settings.layout.color.fixation);
            
            % set flag to true
            vdisplay = true;
            
        end
        
        % if is auditory novel
        if ~adisplay
            
            % play audio
            PsychPortAudio('Start', settings.sound.audiohandle, 1, 0, 1);
            
            % set flag to true
            adisplay = true;
            
        end
        
        % if is haptic novel
        if ~hdisplay && trialseq(it, id.haptic_id) == 1
            
            if trialseq(it,id.nov_h) == 0
            
                % vribrate handle
                vibrate_handle(settings.daq, 1, 'both', 'both'); % vibration on, vibrate both motors to begin with to account for long ramp-up time for left slow motor
                WaitSecs(.01); % Wait 10 ms, then turn off fast
                vibrate_handle(settings.daq, 1, 'both', hapticcue); % now the actual differential vibration slow / fast
                WaitSecs(settings.duration.vibration - .01);
                vibrate_handle(settings.daq, 0); % vibration off
                
            else
                
                vibrate_handle(settings.daq, 1, 'both', 'fast'); % start vib
                
            end
            
            % set flag to true
            hdisplay = true;
            
        elseif ~hdisplay && trialseq(it,id.haptic_id) == 2
            
            if trialseq(it,id.nov_h) == 0
            
                vibrate_handle(settings.daq, 1, 'both', 'fast'); % start vib
                
            else
                
                vibrate_handle(settings.daq, 1, 'both', 'both'); % vibration on, vibrate both motors to begin with to account for long ramp-up time for left slow motor
                WaitSecs(.01); % Wait 10 ms, then turn off fast
                vibrate_handle(settings.daq, 1, 'both', hapticcue); % now the actual differential vibration slow / fast
                WaitSecs(settings.duration.vibration - .01);
                vibrate_handle(settings.daq, 0); % vibration off
                
            end
            
            % set flag to true
            hdisplay = true;
            
        end
        
    end
    
    % STIMULUS OFFSET
    if GetSecs - starttime >= settings.duration.delay + settings.duration.cue
        
        % if is visual novel
        if ~voffset
            
            % flip screen
            DrawFormattedText(OW, stim, owd(3)/2+side, 'center', settings.layout.color.text);
            Screen('Flip', settings.screen.outwindow);
    
            % set flag to true
            voffset = true;
            
        end

        % if is haptic novel
        if ~hoffset
            
            % vribrate off
            vibrate_handle(settings.daq, 0);
            
            % set flag to true
            hoffset = true;
            
        end
        
    end
    
end

% end scan
DAQoptions.continue = 0; DAQoptions.end = 1;
traces = DaqAInScanJRW(daq,DAQoptions);

% compute RT
leftr = find(traces(:,1)>1,1,'first');
rightr = find(traces(:,2)>1,1,'first');
if isempty(leftr) && isempty(rightr)
    RT = 0; Resp = 0;
elseif ~isempty(leftr) && ~isempty(rightr)
    [RT,Resp] = min([leftr rightr]);
elseif ~isempty(leftr)
    RT = leftr; Resp = 1;
elseif ~isempty(rightr)
    RT = rightr; Resp = 2;
end