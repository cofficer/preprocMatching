function [ data ] = insertNan(artfctdef,data)
%This function inserts NaN-values in the data structure where eye artifacts have
%been discovered. Replaces the MEG channel values. 

%Figure out relevant variable with information about how many times on each
%trial there is an artifact and store that in allT. 

fprintf('\n\nExchanging NaNs for artifacts . . .\n')

totalSample        = 0;
artfctdef.id      = [];
allA              = artfctdef.eog.artifact(:,2);
allS              = data.sampleinfo(:,2);
artfctdef.allT    = zeros(size(allS));
pos               = 1; %indexes the number of artifacts in one trial


%%
%Loop through all the artifacts. Compare the end sample with the endsample
%of the trial.
for j   = 1:length(allS)
    for i = 1:length(allA)
        if allA(i) <=allS(j) && artfctdef.eog.artifact(i,1) >= data.sampleinfo(j,1); %Artifact endsample value need also be larger than startsample of the trial.
            artfctdef.allT(j)=artfctdef.allT(j)+1;
            artfctdef.id(j,pos)=i;% "i" in this case will serve as a identification number.
            pos=pos+1;
        else
            pos=1;
            continue
        end
  
    end
end
%%

%Finding the total number of artifacts, including artifacts that cover
%more than one trial. Hence, some artifacts are counted twice since they
%need to be NaN:ed out twice. 

if isempty(artfctdef.id)
    a=1; %Do nothing
else
    artfctdef.id(end,end+1)=0;
end

for trial=1:length(artfctdef.id)
    eachId=1;
    while artfctdef.id(trial,eachId)~=0
        endStartArt     = artfctdef.eog.artifact(artfctdef.id(trial,eachId),1:2);
        
        endStartSample  = data.sampleinfo(trial,1:2);
        
        startNan        = endStartArt(1)-endStartSample(1)+1; %To avoid starting at zero
        endNan          = endStartArt(2)-endStartSample(1);
        totalSample     = totalSample+(endNan-startNan);
        
        data.trial{trial}(:,startNan:endNan)=NaN;
        eachId=eachId+1;
    end
    
end

totalTime=totalSample/1200;

show=sprintf('Removed total time of: %.4f seconds',totalTime);

disp(show)

end



