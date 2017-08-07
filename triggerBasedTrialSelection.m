%select trigger make trials around
%tutorial on trigger based trial selection
clear all;
file='MAb_Matching_20150816_04.ds';


cfg                         = [];
cfg.dataset                 = file;
cfg.trialfun                = 'trialfun_MatchingMEG'; % ft_trialfun_general is the default
cfg.trialdef.eventtype      = 'UPPT001';
cfg.trialdef.eventvalue     = 64; 
cfg.trialdef.prestim        = 1; % in seconds
cfg.trialdef.poststim       = 2; % in seconds
cfg.fsample                 = 1200;
cfg.headerformat = 'ctf_ds';


cfg = ft_definetrial(cfg);
cfg1=cfg;


%%
%preprocessing
cfg.channel    = {'MEG' 'EOG'};
cfg.continuous = 'yes';
data = ft_preprocessing(cfg);

fprintf('\n\nDone preprocessing\n')
%%
%Redefine
data=offset_define(data);

%%
%Visual artifact rejection

cfg=[];
cfg.channel = 'MEG';
artf=ft_databrowser(cfg,data);

%%
MATCHexp_car_artifact

%%
MATCHexp_EOGh_artifact

%%

MATCHexp_EOGv_artifact

%%

MATCHexp_muscle_artifact

%%

MATCHexp_jump_artifact

%%
%Analysis

cfg                 = [];
cfg.channel         = 'MEG';
cfg.vartrllength    = 1;
tl                  = ft_timelockanalysis(cfg, data);




