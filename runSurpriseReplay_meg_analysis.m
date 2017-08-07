% runMIBmeg_analysis
% run preproc and freqanalysis 

clear all; close all;
cd('D:\SurpriseReplay_MEG\data\MEG\raw\'); 
runcfg = [];
runcfg.batchlists = {

% Pilot december (old button regime, trigger codes and distributions
%     'batchSurpriseReplayexp_CR071212'
%     'batchSurpriseReplayexp_J071212'

% Pilot 14-01-13 (old button regime)
%     'batchSurpriseReplayexp_BP1_140113'
%     'batchSurpriseReplayexp_SB1_140113'
%     'batchSurpriseReplayexp_LR1_140113'

% % Data of latest version of task

% %     'batchSurpriseReplayexp_AW1_040213' %no second session, excluded from dataset
% %     'batchSurpriseReplayexp_SM1_070213' %weird artifact in data, did not invite for second session

    'batchSurpriseReplayexp_SB2_160113'
    'batchSurpriseReplayexp_SB2_150413'

    'batchSurpriseReplayexp_SR1_160113'
    'batchSurpriseReplayexp_SR1_280313'
    
    'batchSurpriseReplayexp_SN1_040213'
    'batchSurpriseReplayexp_SN1_250313'

    'batchSurpriseReplayexp_MR1_040213'
    'batchSurpriseReplayexp_MR1_150413'

    'batchSurpriseReplayexp_BP2_050213'
    'batchSurpriseReplayexp_BP2_120213'
    
    'batchSurpriseReplayexp_JW1_050213'
    'batchSurpriseReplayexp_JW1_260313'
    
    'batchSurpriseReplayexp_LR2_070213'
    'batchSurpriseReplayexp_LR2_290513'
    
    'batchSurpriseReplayexp_KH1_080213'
    'batchSurpriseReplayexp_KH1_270313'
    
    'batchSurpriseReplayexp_CR2_080213'
    'batchSurpriseReplayexp_CR2_120213'
    
    'batchSurpriseReplayexp_LK1_250313'
    'batchSurpriseReplayexp_LK1_260313'
    
    'batchSurpriseReplayexp_FH1_270313'
    'batchSurpriseReplayexp_FH1_280313'
    
    'batchSurpriseReplayexp_JP1_170413'
    'batchSurpriseReplayexp_JP1_180413'
    
    'batchSurpriseReplayexp_UD1_180413'
    'batchSurpriseReplayexp_UD1_190413'
    
    'batchSurpriseReplayexp_TW1_180413'
    'batchSurpriseReplayexp_TW1_280513'
    
    'batchSurpriseReplayexp_MW1_180413'
    'batchSurpriseReplayexp_MW1_300513'
    
    'batchSurpriseReplayexp_IP1_190413'
    'batchSurpriseReplayexp_IP1_030613'
    
    'batchSurpriseReplayexp_MS1_190413'
    'batchSurpriseReplayexp_MS1_030613'
    
    'batchSurpriseReplayexp_CS1_270513'
    'batchSurpriseReplayexp_CS1_280513'
    
    'batchSurpriseReplayexp_AT1_280513'
    'batchSurpriseReplayexp_AT1_040613'
    
    'batchSurpriseReplayexp_DH1_030613'
    'batchSurpriseReplayexp_DH1_040613'
};

runcfg.trigger = {
        'resp'
%         'stim'
% 'trialsmib'
%         'baseline'
% 'flickerresp'
% 'flickerstim'
% 'flicker'
        };

%% Peersetup preproc scripts

runcfg.overwrite =1;
runcfg.append_et = 1;
runcfg.sourceloc = 'no';

% % preproc runanalysis settings
runcfg.preproc.loaddata = 'no'; %load in data to do visual muscle rejection
runcfg.preproc.loaddatapath = '/mnt/homes/home020/meindertsmat/data/MEG/preproc/';

runcfg.preproc.artf_rejection = 'yes';
runcfg.preproc.artf_feedback = 'no';
runcfg.preproc.loadartf = 'no';

runcfg.preproc.parallel = 'local'; %torque peer local qsublocal
runcfg.preproc.compile = 'no';

runcfg.preproc.prunemibfromrep = 'no'; % yes

fprintf('Running MIBmeg preproc analysis . . .\n\n')
disp(runcfg.preproc.parallel); disp(runcfg.batchlists); disp(runcfg);

warning off
% 
MIBexp_preproc_peersetup

% MIBexp_plotpie_artifacts

%% Peersetup freq scripts

runcfg.overwrite = 1;
sourceloc = 0;

runcfg.freq.analysistype = {
    'low'
%     'high'
%     'full'
    };

runcfg.freq.phaselocktype = {
    'totalpow'
%     'evoked'
    };

% runcfg.freq.timreq = [25 50]; % high low in minutes
runcfg.freq.timreq = 40; % 

runcfg.freq.parallel = 'local'; %torque peer local 
runcfg.freq.compile = 'no'; % yes no
% 
fprintf('Running MIBmeg freq analysis . . .\n\n')
disp(runcfg.freq.parallel); disp(runcfg.batchlists); disp(runcfg);

% warning off
MIBexp_freqanalysis_peersetup
% 

% 


% % 
% plotTFR_SurpriseReplayexp
% 
% MIBexp_corrfreq_statedur_bands

% 
% plotTFR_stimulusresponse
% 
    




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% qsub beta testing
% % cfg=[]; % simple test
% % % cfg.dataset = '/home/niels/MIBmeg/data/s10_NR/011111/NR011111_run1_tsss.fif';
% cfg.dataset='/home/niels/MIBeeg/DummyData/DummyRecording_01.vhdr';
% compiledfun = qsubcompile('ft_preprocessing');
% data = qsubcellfun(compiledfun, {cfg}, 'memreq', 1024^3, 'timreq', 3, 'backend', 'torque');

% compiledfun = qsubcompile('rand');
% qsubcellfun(compiledfun, {1, 2, 3}, 'memreq', 1024^3, 'timreq', 60)

