
%Repair channels 
cfg=[];
cfg.method='distance';
cfg.badchannel='MLF21';
cfg.neighbours=ft_prepare_neighbours(cfg,data);
cfg.trials='all';
cfg.lambda=1e-5;
cfg.order=4;

cfg.method='nearest';
interp=ft_channelrepair(cfg,data);

%%
%Plotting the results of the reparation. 

% for i=1:length(data.label)
% 
% if data.label{i}==cfg.badchannel
%     badchanIndex=i;
% end
% end
% 
% figure(1);
% hold on;
% plot(interp.time{42},interp.trial{42}(badchanIndex,:),'k')
% plot(data.time{42},data.trial{42}(:,:))




