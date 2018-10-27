function ALTS_blockfeedback(settings,trialseq,it)

% SHORTCUTS
OW = settings.screen.outwindow;
OWD = settings.screen.outwindowdims;

% COLUMNS
id = ALT_columns;

% FONT
Screen('TextSize',settings.screen.outwindow,settings.layout.size.blockfeedback);

% COLLECT STATS
blocktrials = trialseq(trialseq(:,id.block) == trialseq(it,id.block),:);
GoRT = mean(blocktrials(blocktrials(:,id.acc)==1, id.rt));
missfail = blocktrials(blocktrials(:,id.acc)==2 | blocktrials(:,id.acc)==99,:);
succstop = blocktrials(blocktrials(:,id.acc)==5,:);
nogotrials = blocktrials(blocktrials(:,id.nogo) == 1,:);
stopsucc = 100 * (size(succstop,1) / (size(nogotrials,1)));
if isnan(stopsucc); stopsucc = 0; end

% BLOCK FEEDBACK
DrawFormattedText(OW, ['Block #' num2str(trialseq(it,id.block)) '/' num2str(trialseq(end,id.block)) ' Summary'], 'center', OWD(4)-1000, settings.layout.color.text);
DrawFormattedText(OW, ['Mean correct RT: ' num2str(round(GoRT))], 'center', OWD(4)-800, settings.layout.color.text);
DrawFormattedText(OW, ['Number of Go-trial Misses / Errors: ' num2str(size(missfail,1))], 'center', OWD(4)/2, settings.layout.color.text);
DrawFormattedText(OW, ['Percentage of successful stops: ' num2str(stopsucc)], 'center', OWD(4)-400, settings.layout.color.text);
DrawFormattedText(OW, 'Rest a few seconds, then press any key to continue...', 'center', OWD(4)-200, settings.layout.color.text);
Screen('Flip', OW);
WaitSecs(3); KbWait(-1);

% play intro on every block except the last
if it < size(trialseq,1)
    ALTS_intro(settings, trialseq, it);
end