function data=offset_define(data)

%%Redefine trials.
fsample=1200;
prestim=1;
poststim=2;

offset=data.trialinfo(:,4);
offset=offset-data.sampleinfo(:,1);
% timelock

%warning off;

cfg = [];

cfg.begsample       = round(offset - prestim*fsample); % take offset into account

cfg.endsample       = round(offset + poststim*fsample-1);

data                = ft_redefinetrial(cfg, data);

end