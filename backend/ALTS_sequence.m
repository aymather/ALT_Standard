function trialseq = ALTS_sequence(settings,id)

trialseq = [];

% SHORTCUTS
col = length(fieldnames(id));

    % BUILD TRIAL SEQUENCE
    for ib = 1:settings.general.blocks

        % GET TRIAL NUMS
        go_nov_a = (settings.general.trials * settings.general.go * settings.general.nov_a);
        go_nov_v = (settings.general.trials * settings.general.go * settings.general.nov_v);
        go_nov_h = (settings.general.trials * settings.general.go * settings.general.nov_h);
        go_stan = (settings.general.trials * settings.general.go) - (go_nov_a + go_nov_v + go_nov_h);
        nogo_nov_a = (settings.general.trials * settings.general.nogo * settings.general.nov_a);
        nogo_nov_v = (settings.general.trials * settings.general.nogo * settings.general.nov_v);
        nogo_nov_h = (settings.general.trials * settings.general.nogo * settings.general.nov_h);
        nogo_stan = (settings.general.trials * settings.general.nogo) - (nogo_nov_a + nogo_nov_v + nogo_nov_h);

        %go_nov_a
        go_nov_a = zeros(go_nov_a, col);
        go_nov_a(1:size(go_nov_a,1)/2, id.side) = 1;
        go_nov_a(size(go_nov_a,1)/2+1:end, id.side) = 2;
        go_nov_a(:,id.nov_a) = 1;
        go_nov_a(:,id.go) = 1;

        %go_nov_v
        go_nov_v = zeros(go_nov_v, col);
        go_nov_v(1:size(go_nov_v,1)/2, id.side) = 1;
        go_nov_v(size(go_nov_v,1)/2+1:end, id.side) = 2;
        go_nov_v(:,id.nov_v) = 1;
        go_nov_v(:,id.go) = 1;

        %go_nov_h
        go_nov_h = zeros(go_nov_h, col);
        go_nov_h(1:size(go_nov_h,1)/2, id.side) = 1;
        go_nov_h(size(go_nov_h,1)/2+1:end, id.side) = 2;
        go_nov_h(:,id.nov_h) = 1;
        go_nov_h(:,id.go) = 1;

        %go_stan
        go_stan = zeros(go_stan, col);
        go_stan(1:size(go_stan,1)/2, id.side) = 1;
        go_stan(size(go_stan,1)/2+1:end, id.side) = 2;
        go_stan(:,id.go) = 1;

        %nogo_nov_a
        nogo_nov_a = zeros(nogo_nov_a, col);
        nogo_nov_a(1:size(nogo_nov_a,1)/2, id.side) = 1;
        nogo_nov_a(size(nogo_nov_a,1)/2+1:end, id.side) = 2;
        nogo_nov_a(:,id.nov_a) = 1;
        nogo_nov_a(:,id.nogo) = 1;

        %nogo_nov_v
        nogo_nov_v = zeros(nogo_nov_v, col);
        nogo_nov_v(1:size(nogo_nov_v,1)/2, id.side) = 1;
        nogo_nov_v(size(nogo_nov_v,1)/2+1:end, id.side) = 2;
        nogo_nov_v(:,id.nov_v) = 1;
        nogo_nov_v(:,id.nogo) = 1;

        %nogo_nov_v
        nogo_nov_h = zeros(nogo_nov_h, col);
        nogo_nov_h(1:size(nogo_nov_h,1)/2, id.side) = 1;
        nogo_nov_h(size(nogo_nov_h,1)/2+1:end, id.side) = 2;
        nogo_nov_h(:,id.nov_h) = 1;
        nogo_nov_h(:,id.nogo) = 1;

        %nogo_stan
        nogo_stan = zeros(nogo_stan, col);
        nogo_stan(1:size(nogo_stan,1)/2, id.side) = 1;
        nogo_stan(size(nogo_stan,1)/2+1:end, id.side) = 2;
        nogo_stan(:,id.nogo) = 1;

        %merge
        block = [go_nov_a; go_nov_h; go_nov_v; go_stan; nogo_nov_a; nogo_nov_h; nogo_nov_v; nogo_stan]; % this could be more elegant by busing the variable instead

        %randomize
        nov_trials = randperm(size(block,1));
        criteria = sum(diff(sort(nov_trials(1:size(go_nov_a,1) + size(go_nov_h,1) + size(go_nov_v,1) + size(nogo_nov_a,1) + size(nogo_nov_h,1) + size(nogo_nov_v,1))))==1);
        while criteria > 0
            nov_trials = randperm(size(block,1));
            criteria = sum(diff(sort(nov_trials(1:size(go_nov_a,1) + size(go_nov_h,1) + size(go_nov_v,1) + size(nogo_nov_a,1) + size(nogo_nov_h,1) + size(nogo_nov_v,1))))==1);
        end

        randnov = nov_trials(1:size(go_nov_a,1) + size(go_nov_h,1) + size(go_nov_v,1) + size(nogo_nov_a,1) + size(nogo_nov_h,1) + size(nogo_nov_v,1));
        randstan = nov_trials(size(go_nov_a,1) + size(go_nov_h,1) + size(go_nov_v,1) + size(nogo_nov_a,1) + size(nogo_nov_h,1) + size(nogo_nov_v,1) + 1:end);
        ntrials = [go_nov_v; go_nov_a; go_nov_h; nogo_nov_a; nogo_nov_h; nogo_nov_v];
        ntrials = ntrials(randperm(size(ntrials,1)),:);
        block(randnov,:) = ntrials;
        stan = [go_stan; nogo_stan];
        stan = stan(randperm(size(stan,1)),:);
        block(randstan,:) = stan;

        % BLOCK NUMBER
        block(:,id.block) = ib;

        % MERGE
        trialseq = [trialseq; block];

    end

    % TRIAL NUMBERS
    trialseq(:,id.num) = 1: settings.general.trials*settings.general.blocks;
    
    % DEADLINE
    trialseq(:,id.deadline) = settings.duration.deadline; % to be adapted: deadline

end