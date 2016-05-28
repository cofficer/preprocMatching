

% MATCHexp_muscle_artifact
fprintf('\n\nLooking for MUSCLE artifacts . . .\n')
cfg     = [];
cfg.datafile = cfg1.datafile;
cfg.headerfile = cfg1.datafile;
cfg.headerformat = 'ctf_ds';
cfg.trl = data.cfg.trl;
cfg.continuous = 'yes';
% channel selection: "Ceasar's krans"
% cfg.artfctdef.zvalue.channel = {'MEG081*', 'MEG091*', 'MEG121*', 'MEG141*', 'MEG142*', 'MEG143*', 'MEG144*', 'MEG262*', 'MEG263*', 'MEG253*', 'MEG254*', 'MEG213*', 'MEG214*', 'MEG174*', 'MEG171*', 'MEG153*', 'MEG154*', 'MEG014*', 'MEG013*', 'MEG011*', 'MEG012*', 'MEG031*', 'MEG051*', 'MEG052*'};
% cfg.artfctdef.zvalue.channel = [cfg1.channel {'-EOG'}];  %'M*1'

% cfg.artfctdef.zvalue.channel = 'M*1'; %mags only
cfg.artfctdef.zvalue.channel = {'MEG'};  %grads only

%Reject set to replace muscle artifacts with NaNs
cfg.artfctdef.reject='nan';

% cutoff and padding
cfg.artfctdef.zvalue.cutoff      = cfg1.musclethr;
cfg.artfctdef.zvalue.trlpadding  = 0; 
cfg.artfctdef.zvalue.fltpadding  = 0.2; 
cfg.artfctdef.zvalue.artpadding  = 0.1;
% algorithmic parameters
cfg.artfctdef.zvalue.bpfilter    = 'yes';
cfg.artfctdef.zvalue.bpfreq      = [110 140];
cfg.artfctdef.zvalue.bpfiltord   = 9;
cfg.artfctdef.zvalue.bpfilttype  = 'but';
cfg.artfctdef.zvalue.hilbert     = 'yes';
cfg.artfctdef.zvalue.boxcar      = 0.2;
% feedback
cfg.artfctdef.zvalue.interactive = interactive;
cfg.artfctdef.reject='partial';
[cfg, artfctdef.muscle.artifact ] = ft_artifact_zvalue(cfg);

fprintf('%d muscle artifacts found\n', length(artfctdef.muscle.artifact))

data=insertNan(artfctdef,data);


%data  = ft_rejectartifact(cfg,data);