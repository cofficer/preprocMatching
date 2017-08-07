

%%Redefine trials.
fsample=1200;
prestim=1;
poststim=2;

offset=dataFIC.trialinfo(:,4);
offset=offset-dataFIC.sampleinfo(:,1);
% timelock

%warning off;

cfg = [];

cfg.begsample       = round(offset - prestim*fsample); % take offset into account

cfg.endsample       = round(offset + poststim*fsample);

data                = ft_redefinetrial(cfg, dataFIC);

