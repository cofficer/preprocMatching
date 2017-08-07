% MIBexp_preproc_peersetup
% run from runMIBmeg_analysis

cfg1 = {};
cfg2 = {};
cfg3 = {};
outputfile = {};
overwrite = runcfg.overwrite;

%make cells for each subject, to analyze in parallel
ctr = 1;
for isub = 1:length(runcfg.batchlists)
    eval(runcfg.batchlists{isub}); %load in batchlist file, batch, PREOUT and PREIN come out
    
    PREIN = fullfile('/mnt/homes/home024/meindertsmat/data/Matching/MEG/raw/', PRE);
    %PREIN = fullfile('/home/pmurphy/meg_data/');
    PREOUT = fullfile('/home/chrisgahn/Documents/MATLAB/preprocessed/', PRE); %/Users/nkloost1/Dropbox/PROJECTS/MIBmeg/MIBmeganalysis/preproc/
    %         PREOUT = fullfile('/Users/nkloost1/Dropbox/PROJECTS/MIBmeg/MIBmeganalysis/preproc/', PRE); %

    for irun=1:length(batch)
        for itrg = 1:length(runcfg.trigger)
            outfile = sprintf('%s%s_%s_%s_%s_data', PREOUT, batch(irun).subj, batch(irun).type, runcfg.trigger{itrg}); %batch(irun).filter
            %             if ~exist([outfile '.mat'], 'file') || overwrite % if the matfile does not yet exist, then add to the joblist
            if exist([outfile '.mat'], 'file') && ~overwrite % if the matfile does not yet exist, then add to the joblist
                fprintf('%s exists and overwrite turned off! Skip it\n', outfile); continue
            end   %%% if ~exist([outfile '.mat'], 'file')
            
            outputfile{ctr} = outfile;
            cfg1{ctr}.runcfg = runcfg;  %analysis specifics
            cfg1{ctr}.runcfg.PRE = PRE;  %analysis specifics
            cfg1{ctr}.runcfg.prunemibfromrep = 'no';
            cfg1{ctr}.runcfg.type = batch(irun).type;  %exp type
            cfg1{ctr}.datafile= sprintf('%s%s', PREIN, batch(irun).dataset);
            cfg1{ctr}.headerfile = cfg1{ctr}.datafile;
            cfg1{ctr}.headerformat = ft_filetype(cfg1{ctr}.datafile); % 'neuromag_fif'
            cfg1{ctr}.channel =  {'MEG','EOG', '-MEG*1'}; %exclude magnetometers! % batch(irun).channel
            cfg1{ctr}.fsample = 1200;
            cfg1{ctr}.trialfun = 'trialfun_MatchingMEG17nov'; %sortTrials_MIBexperiment
            cfg1{ctr}.trialdef.trg = runcfg.trigger{itrg}; %baseline, stim or resp
            cfg1{ctr}.dftfilter = 'yes';
            cfg1{ctr}.dftfreq = [50 100 150 200];  % line noise removal using discrete fourier transform
            cfg1{ctr}.demean = 'yes';
            cfg1{ctr}.padding   = 1;
            cfg1{ctr}.continuous = 'yes';
            cfg1{ctr}.numcfg    = irun; %To track which cfg is analyzed. 

            switch runcfg.trigger{itrg}                     % Note: padding for taper timewin added in sorttrials!
                case 'baseline'
                    cfg1{ctr}.trialdef.begtim = 0;
                    cfg1{ctr}.trialdef.endtim = 2;
                case 'flicker'
                    cfg1{ctr}.trialdef.begtim = -0.5;    %for trigger flicker experiment
                    cfg1{ctr}.trialdef.endtim = 1.5;
                case 'trialsmib'
                    cfg1{ctr}.trialdef.begtim = -0.5;
                    cfg1{ctr}.trialdef.endtim = 1.75;
                case 'flickerstim' % stim or resp
                    cfg1{ctr}.runcfg.prunemibfromrep = runcfg.preproc.prunemibfromrep; % only when rep condition present
                    cfg1{ctr}.trialdef.begtim = -1.5;
                    cfg1{ctr}.trialdef.endtim = 3;
                case 'ssvep_pilot3'
                    cfg1{ctr}.trialdef.begtim = -1;  % freqanalysis: -0.75 to 2
                    cfg1{ctr}.trialdef.endtim = 2.25;
                otherwise % stim or resp
                    cfg1{ctr}.runcfg.prunemibfromrep = runcfg.preproc.prunemibfromrep; % only when rep condition present
                    cfg1{ctr}.trialdef.begtim = -1.5;
                    cfg1{ctr}.trialdef.endtim = 1.5;
            end
            cfg1{ctr}.artfrej = runcfg.preproc.artf_rejection; %do artifact rejection? yes
            cfg1{ctr}.artf_feedback = runcfg.preproc.artf_feedback; %feedback for inspection automatic artf detection
            cfg1{ctr}.loadartf = runcfg.preproc.loadartf;%load from file?
            %automatic artf detection: cfg specified in resp scripts
            cfg1{ctr}.musclethr = batch(irun).musclethr;
            %cfg1{ctr}.musclethr = 7.5; %!!! fixed
            cfg1{ctr}.jumpthr   = batch(irun).jumpthr;
            cfg1{ctr}.carthr    = batch(irun).carthr;
            cfg1{ctr}.eoghorthr = batch(irun).eoghorthr;
            cfg1{ctr}.eogverthr = batch(irun).eogverthr;
            % visual artifact rejection parameters
            cfg2{ctr}.method   = 'summary'; % channel trial summary
            cfg2{ctr}.channel = 'MEG';
            cfg2{ctr}.alim     = 1e-10;
            cfg2{ctr}.megscale = 1;
            cfg2{ctr}.eogscale = 5e-8;
            cfg2{ctr}.layout = '/home/niels/matlab/fieldtrip/template/layout/neuromag306all.lay';       %neuromag306cmb neuromag306all neuromag306mag neuromag306planar
            
            %resampling parameters
            cfg3{ctr}.resample = 'yes';
            cfg3{ctr}.fsample = 1200;
            cfg3{ctr}.resamplefs = 500;
            cfg3{ctr}.detrend = 'no'; % ft: not good for evoked fields . . .???
            
            ctr = ctr + 1;
        end
    end
    clear batch
end
fprintf('Running MIBexp_preproc for %d cfgs\n', length(cfg1))

switch runcfg.preproc.parallel
    case 'local'
        cellfun(@MIBexp_preproc, cfg1, cfg2, cfg3, outputfile);
    case 'peer'
        peercellfun(@MIBexp_preproc, cfg1, cfg2, cfg3, outputfile);
    case {'torque' 'qsublocal' } %'local'}
        %             ntest=1; % for testing with qsub
        %             outputfile=outputfile(1:ntest); cfg1=cfg1(1:ntest); cfg2=cfg2(1:ntest); cfg3=cfg3(1:ntest);
        
        %         timreq = 12; %in minutes per run
        timreq = 2; %in minutes per run
        setenv('TORQUEHOME', 'yes')
        mkdir('~/qsub'); cd('~/qsub');
        switch runcfg.preproc.compile
            case 'no'
                nnodes = 32; % how many licenses available?
                stack = round(length(cfg1)/nnodes); % only used when not compiling
                qsubcellfun(@MIBexp_preproc, cfg1, cfg2, cfg3, outputfile, 'memreq', 1024^3, 'timreq', timreq*60, ...
                    'stack', stack, 'StopOnError', true, 'backend', runcfg.preproc.parallel);
            case 'yes'
                compiledfun = qsubcompile({@MIBexp_preproc @sortTrials_MIBexperiment}, 'toolbox', {'signal', 'stats'});
                qsubcellfun(compiledfun, cfg1, cfg2, cfg3, outputfile, 'memreq', 1024^3, 'timreq', timreq*60, ...
                    'stack', 1, 'StopOnError', true, 'backend', runcfg.preproc.parallel);
        end
    otherwise
        error('Unknown backend, aborting . . .\n')
end

