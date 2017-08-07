%Automatic artifact rejection - cars

% MATCHexp_car_artifact
fprintf('\n\nLooking for CAR artifacts . . .\n')
cfg     = [];
cfg.datafile = cfg1.datafile;
cfg.headerfile = cfg1.headerfile;
cfg.trl = cfg1.trl;
cfg.continuous = 'yes';
cfg.artfctdef.threshold.channel = {'MEG'};
cfg.artfctdef.threshold.bpfilter = 'no';
cfg.artfctdef.threshold.range = cfg1.carthr;


% feedback 
cfg.artfctdef.feedback=interactive;
[cfg, artfctdef.threshold.artifact ] = ft_artifact_threshold(cfg,data);

%In order to make sure there is no overlap of trials,
%the trial selection is around the mean of each trial. 


%Find the trials to be kept.
trialsToKeep=1:length(cfg.trl);
trialToRemoveAll=[];

if isempty(artfctdef.threshold.artifact)
    trialsToRemoveAll=[];
else
    for numArt=1:length(artfctdef.threshold.artifact(:,1))
        
        trialToRemove=find(data.sampleinfo==artfctdef.threshold.artifact(numArt,1));
        
        trialToRemoveAll=[trialToRemoveAll,trialToRemove];
        
    end
end

trialsToKeep(trialToRemoveAll)=[];

cfg.artfctdef.threshold.artifact=artfctdef.threshold.artifact;

fprintf('%d car artifacts found\n', length(artfctdef.threshold.artifact))


data=ft_selectdata(data,'rpt',trialsToKeep);

%data  = ft_rejectartifact(cfg,data); %182/206

