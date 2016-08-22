function [trl, event] = trialfun_MatchingMEG(cfg)
% header and events are already in the asc structures
% returns a trl that should be identical to the structure obtained from MEG
% data

%define triggers
fix         = 64;     %fixation onset
stimH       = 48;   %stimulus horizontal onset
stimV       = 52;   %stimulus vertical onset
goCue       = 40;   %go cue onset;
respHR      = 23;   %response horizontal right 
respHL      = 21;   %response horizontal left
respVR      = 22;   %response vertical right
respVL      = 20;   %response vertical left
feed0       = 11;   %no feedback signal onset
feed1       = 10;   %feedback signal onset
startblock  = 32; %New block onset
feed2      = 16; %No response
feed3   = 18; %Early response

%All triggers
trigAll     =[64,48,52,40,32,23,21,22,20,18,16,11,10];

hdr    = cfg.headerfile;
fsr    = cfg.fsample;         % in Hz
begtrl = 1; % in seconds cfg.trialdef.prestim
endtrl = 2; % in seconds cfg.trialdef.poststim


%Store the events

event = ft_read_event(hdr);%'headerformat',[],'eventformat',[],'dataformat',[]
    


% start by selecting all events
trgval = strcmp('UPPT001',{event.type}); % this should be a row vector
trgvalIndex = find(trgval);


%newBlock is a list consisting of which trials a new block starts. 
newBlock=[];

%Load the restored triggers from the relevant file. 
if isempty(trgvalIndex);
    clear event %Making a new one
    oldfolder=pwd;
    chFolder=sprintf('%s',cfg.datafile(1:end-27));
    cd(chFolder)
    listEventFile=dir('*.mat');
    %Need to load in all the events structs, not just one. 
    for loadMat=1:length(listEventFile)
        
        %This number is dependant on how many datafiles are in a session.
        numDS=str2double(cfg.datafile(end-3));
        
        if str2double(listEventFile(loadMat).name(end-10))==numDS
            eventNew=load(listEventFile(loadMat).name);
            
            
            
            
            if exist('event','var')
                event=[event; eventNew.event];
            else
                event=eventNew.event;
            end
                
            
        end
        
        %matFile=listEventFile(str2double(cfg.datafile(end-3))).name;
        %event=load(matFile(loadMat));
        %event=event.event;
        
    end
  
    cd(oldfolder)
    
    
    trgval = strcmp('UPPT001',{event.type}); % this should be a row vector
    trgvalIndex = find(trgval);
    trgvalIndex = [1:length(event)];
    
    %Changed from '0'
    numIn2=0;
    %Total number of trials
    totalTrial=0;
    %Loop over all events and store the current trial in the event
    %structure. 
    for k   = 1:length(event) 
        
        
        
        %New way to find the correct trial for each event. 
        locUnderscore=strfind(event(k).ETtrigger,'_');
        
        %There is a startpause trigger sometimes between blocks. 
        try
            numIn   = str2double(event(k).ETtrigger(locUnderscore(1)+6:locUnderscore(2)-1));
        
        catch 
            msg=event(k).ETtrigger;
            warning(msg);
            disp(msg)
            
        end
        
        %In some events there is no trial number, and then numIn will be
        %NaN
        if isnan(numIn)
            continue
        else
            event(k).CurrTrial  = int8(numIn); %Store the current trial 
            
            %During first loop store away numIn for coming loops
            if k==1
                
                numIn2  = int16(numIn);
            
            %Look for block changes by comparing trial numbers
            elseif k>2
                
                if numIn2>numIn
                    %The trial where a change of block occurs                   
                    totalTrial=totalTrial+numIn2;
                    newBlock=[newBlock;totalTrial];
                end
                numIn2  = int16(numIn);
            end
           
        end
        
        
        
        
        
        
        
%         numIn   = event(k).ETtrigger(13);
%         
%        % Check if trial number is made of two digits. 
%         if isstrprop(event(k).ETtrigger(14),'digit') && isstrprop(event(k).ETtrigger(13),'digit')
%             
%             numIn   = event(k).ETtrigger(13:14);
%         elseif isstrprop(event(k).ETtrigger(14),'digit') && isstrprop(event(k).ETtrigger(15),'digit')
%         
%             numIn   = event(k).ETtrigger(14:15);
%         end 
%         
%         %If the current trial is smaller than the previous trial, there is a new block. 
%         if str2num(numIn)<str2num(numIn2)
%             if isstrprop(numIn,'digit')
%                 newBlock=[newBlock;str2num(numIn2)];
%             end
%         end    
%         
%         %Need to check if the trial number is reset to identify blockchange.
%         if k>1
%             numIn2=numIn;
%         end
%         
%         event(k).CurrTrial=str2num(numIn);
%         if event(k).CurrTrial == [];
%             a=1;
%         end
    end
end


%Convert from logical to double. 
trgval=double(trgval);

% select all events with the specified value
if isfield(cfg.trialdef, 'eventvalue') && ~isempty(cfg.trialdef.eventvalue)
  for i=trgvalIndex
      
      %Find the event from the possible triggers
      currT=trigAll(trigAll==event(i).value);
      if currT >1;
        trgval(i)=currT;
      end

  end
end

%Create a matrix with all the relevant trigger columns + offsets etc.
trl=zeros(sum(trgval==goCue),numel(trigAll)+1); %Actually empty var. 

%Establish point of reference after each trigger==64. Counting trials. 
trlN=1;
%Define trloff (trial offset). Need to be a running value during each
%trial. 
trloff=0;

for i=1:length(trgvalIndex)
    
    %If the trigger is not yet implemented, skip it for now.
    if isempty(trigAll(trigAll==event(trgvalIndex(i)).value))
        continue
    end
    %catch empty fields in the event table and interpret them meaningfully
    if isempty(event(trgvalIndex(i)).offset)
        % time axis has no offset relative to the event
        event(trgvalIndex(i)).offset = 0;
    end
    if isempty(event(trgvalIndex(i)).duration)
        % the event does not specify a duration
        event(trgvalIndex(i)).duration = 0;
    end
    % determine where the trial starts with respect to the event
    if ~isfield(cfg.trialdef, 'prestim')
        trloff = trloff+event(trgvalIndex(i)).offset;
        trlbeg = event(trgvalIndex(i)).sample;
    else
        % override the offset of the event
        trloff = round(-cfg.trialdef.prestim*fsr);
        % also shift the begin sample with the specified amount
        trlbeg = event(trgvalIndex(i)).sample + trloff;
    end
    
    
    %Start of a new trial. 
    switch event(trgvalIndex(i)).value
        case fix;
            %trl(trlN,1)=trlbeg;
            trl(trlN,3)=event(trgvalIndex(i)).sample;
            trl(trlN,4)=fix;
            trl(trlN,14)=trlN;
            trloff=0;
        case {stimH,stimV}
            %Simulus onset trial offset
            trl(trlN,5)=event(trgvalIndex(i)).sample;
            trl(trlN,6)=event(trgvalIndex(i)).value;
            %Trial start 2s before Stimulus onset
            trl(trlN,1)=event(trgvalIndex(i)).sample-1200*2;
            
            
            
        case goCue
            %Onset of go cue
            trl(trlN,7)=event(trgvalIndex(i)).sample;
            trl(trlN,8)=event(trgvalIndex(i)).value;
        case {respHR,respHL,respVR,respVL}
            %response triggers
            trl(trlN,9)=event(trgvalIndex(i)).sample;
            trl(trlN,10)=event(trgvalIndex(i)).value;
        case {feed0,feed1,feed2, feed3}
            trl(trlN,11)=event(trgvalIndex(i)).sample;
            trl(trlN,12)=event(trgvalIndex(i)).value;
            %Adding 2.4s to include more data after feedback. 
            trl(trlN,2)=event(trgvalIndex(i)).sample+endtrl*fsr;
            if i==495
                aa=1;
            end
            trlN=trlN+1;
        case {startblock}
            %trl(trlN,13)=event(trgvalIndex(i)).sample;
            trl(trlN,13)=event(trgvalIndex(i)).value;
    
    end

end


if strcmp(cfg.datafile, '/home/meindertsmat/data/Matching/MEG/raw/HEn/20150828/HEn_Matching_20150828_01.ds')
    trl=trl(7:end,:);
end

if sum(trl(:,13))==0
    trl(newBlock,13)=32;% 187766-128640
    trl(1,13)=32;
    %insert new block start
end
end
