function [Queue,Status]=fGetServerQueue
DirServer = fShared('CheckServer');
Queue=[];
Status=[];
if ~isempty(DirServer)
    for n=1:2
        files=dir([DirServer 'Queue' filesep 'Job' num2str(n) filesep 'FiestaQueue*.mat']);
        if ~isempty(files)
            try
                addQueue = fLoad([DirServer 'Queue' filesep 'Job' num2str(n) filesep files(1).name],'ServerQueue');
                addStatus = load([DirServer 'Queue' filesep 'Job' num2str(n) filesep 'FiestaStatus.mat']);
                addStatus.JobNr = n;
            catch ME
                addStatus = [];
                addQueue = [];
            end
            Queue = [Queue addQueue];
            Status = [Status addStatus];
        end
    end
    files=dir([DirServer 'Queue' filesep 'FiestaQueue*.mat']);
    if ~isempty(files)
        for n=1:length(files)
            try
                addQueue=fLoad([DirServer 'Queue' filesep files(n).name],'ServerQueue');
            catch
                addQueue=[];
            end
            Queue = [Queue addQueue];
        end
    end
end