function trialseq = ALTS_backend(settings,trialseq,id)

% SHORTCUTS
FC = settings.layout.color.fixation;
OW = settings.screen.outwindow;
owd = settings.screen.outwindowdims;

% INTRO
ALTS_intro(settings, trialseq, 1);

% Randomly assign to slow/fast haptic nov
if rand >= .5; trialseq(:,id.haptic_id) = 1; else trialseq(:,id.haptic_id) = 2;end

% TRIAL LOOP
for it = 1:size(trialseq,1)
    
    % Buffer Audio
    if trialseq(it,id.nov_a) == 1; wavdata = settings.sound.novelsounds{1,1}'; else wavdata = settings.sound.standardsound; end
    PsychPortAudio('FillBuffer', settings.sound.audiohandle, wavdata); % buffer sound
    
    % PREP V NOVEL
    if trialseq(it, id.nov_v) == 1
        % color
        r1 = randperm(length(settings.layout.color.options)-1);
        colors = 2:length(settings.layout.color.options);
        color = colors(r1(1));
        % symbol
        r1 = randperm(9);
        symbols = 1:9;
        symbol = symbols(r1(1));
    else
        color = 1; % green
        symbol = 10; % circle
    end
    
    videocue = ALTS_makevisualcue(settings,symbol,color);
    
    % START TIME
    if it == 1; begintime = GetSecs; end
    trialseq(it, id.time) = GetSecs - begintime;
    
    % FIXATION
    DrawFormattedText(OW, '+', 'center', 'center', FC);
    trial_start = Screen('Flip', OW);
    WaitSecs(settings.duration.fixation);
    
    % MAP BUTTONS
    if trialseq(it, id.go) == 1
        stim = settings.general.buttons{1};
    else
        stim = settings.general.buttons{2};
    end
    if trialseq(it, id.side) == 1
        side = -settings.layout.size.offset-settings.layout.size.text/2;
    else
        side = settings.layout.size.offset-settings.layout.size.text/2;
    end
    
    % DRAW STIMULUS
    DrawFormattedText(OW, '+', 'center', 'center', FC);
    DrawFormattedText(OW, stim, owd(3)/2+side, 'center', settings.layout.color.text);
    stimonset = Screen('Flip', OW);
    
    eval(videocue);
    
    % CHECK FOR RESPONSE
    [trialseq(it,id.rt), trialseq(it,id.resp)] = handle_response_ALTS(settings.daq,(trialseq(it,id.deadline)+settings.duration.post_deadline)*1000,settings,trialseq,id,it,OW,stim,owd,side);

    % CODE RESPONSE - (accuracy_legend.m for key)
    if trialseq(it,id.go) == 1
        if trialseq(it,id.resp) == 0 || trialseq(it,id.rt) >= trialseq(it,id.deadline)*1000
            trialseq(it,id.acc) = 99; % miss
        elseif trialseq(it,id.resp) == trialseq(it,id.side) && trialseq(it,id.rt) < trialseq(it,id.deadline)*1000
            trialseq(it,id.acc) = 1; % correct
        elseif trialseq(it,id.resp) ~= trialseq(it,id.side) && trialseq(it,id.rt) < trialseq(it,id.deadline)*1000
            trialseq(it,id.acc) = 2; % error
        end
    else
        if trialseq(it,id.rt) <= trialseq(it,id.deadline)*1000 && trialseq(it,id.resp) ~= 0
            trialseq(it,id.acc) = 3; % failstop
        elseif trialseq(it,id.rt) >= trialseq(it,id.deadline)*1000
            trialseq(it,id.acc) = 4; % not a true successful stop
        elseif trialseq(it,id.rt) == 0 && trialseq(it,id.resp) == 0
            trialseq(it,id.acc) = 5; % true successful stop
        end
    end
    
    % feedback
    if trialseq(it,id.acc) == 99
        DrawFormattedText(settings.screen.outwindow, 'TOO SLOW!', 'center', 'center', settings.layout.color.SLOW);
        Screen('Flip', settings.screen.outwindow);
    end
    
    % SAVE
    save(fullfile(settings.files.outfolder,settings.files.outfile),'trialseq','settings');
    
    if it < size(trialseq,1)
        % adjust deadline
        if trialseq(it,id.acc) == 99
            trialseq(it+1:end,id.deadline) = trialseq(it,id.deadline) + settings.duration.deadlineadjust;
        else
            % get go trials
            gos = trialseq(trialseq(1:it,id.go)==1,:);
            if size(gos,1) >=5 && gos(end,id.acc) == 1 && gos(end-1,id.acc) == 1 && gos(end-2,id.acc) == 1
                trialseq(it+1:end,id.deadline) = trialseq(it,id.deadline) - settings.duration.deadlineadjust;
            end
        end  
    end
    
    % PREVENT TRIAL OVERLOAD
    if it+1 < size(trialseq,1)
        if trialseq(it+1,id.deadline) < .25
            trialseq(it+1:end,id.deadline) = .25;
        end    
    end
    
    WaitSecs(settings.duration.iti);
    
    % BLOCK BREAK
    if it == size(trialseq,1) || trialseq(it,id.block) ~= trialseq(it+1,id.block)
        ALTS_blockfeedback(settings,trialseq,it)
    end
    
end