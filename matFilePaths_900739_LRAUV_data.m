function [ matFilePaths, matFileNames, filePath, logName ] = matFilePaths_900739_LRAUV_data( yr, serverpath )

% This function locates .mat files from server folders and logs thier paths
% Last modified Dec. 22, 2014
% Ben Raanan

% INPUTS:
% serverpath = '/Volumes/900739.LRAUV.data/Testing/';
% yr = 2013; (e.g., 2010,2011,...,2014) 
%--------------------------------------------------------------------------

pathFolder = [serverpath num2str(yr) '/'];

% find folder subdirectories
%--------------------------------------------------------------------------
d = dir(pathFolder);
isub = [d(:).isdir]; %# returns logical vector
nameFolds = {d(isub).name}';

% eliminate nonrelevent directories
ignore  = {' ','.','..','latest','Lab','Tank','Tow','Battery'};
for c=1:length(ignore)
    ci = (cellfun('isempty', strfind(nameFolds,ignore{c})));
    nameFolds = nameFolds(ci);
end; clear c ci;

% GET .MAT FILES FROM SERVER
%--------------------------------------------------------------------------
fName = cell(1);
logs  = cell(1,3);
matpath = cell(1);
matname = cell(1); matCount = 0;
for j=1:length(nameFolds)
    
    % folder path
    tmp = [pathFolder nameFolds{j} '/Logs/'];
    
    % find folder subdirectories
    d = dir(tmp);
    isub = [d(:).isdir];       %# returns logical vector
    X = {d(isub).name}';
    
    % eliminate nonrelevent directories
    ci = not(cellfun('isempty', strfind(X,num2str(yr))));
    X = X(ci);
    
    % log names
    in = size(fName,1)+1;
    ind = in:length(X)+in-1;
    logs(ind,2) = X;
    
    % concatanate to form .mat file paths
    for k=1:length(ind)
        logs{ind(k),1} = nameFolds{j};
        fName{ind(k),:} = strcat(tmp,X{k},'/');
        
        % locate relevant .mat files within each log
        w = what(fName{ind(k)});
        m1 = not(cellfun('isempty',regexp(w.mat, ['^' num2str(yr)])));
        m2 = cellfun('length', w.mat)==29;
        logs{ind(k),3} = w.mat(m1 & m2);
        
        % log relevant .mat files paths and names
        for m = 1:numel(logs{ind(k),3})
            matCount = matCount+1;
            tmpmat=logs{ind(k),3};
            matpath{matCount,:} = strcat(fName{ind(k),:},tmpmat{m});
            matname{matCount,:} = tmpmat{m};
        end; clear m
    end; clear k;
end; clear j in ind isub d ci X;
fName(1)=[];
logs(1,:) =[];


% Reorganize output structs
%--------------------------------------------------------------------------
% Filter log paths and log-names for each vehicle
b = not(cellfun('isempty', regexpi(fName,'daphne')));
c = not(cellfun('isempty', regexpi(fName,'makai'))); 
a = ~(b | c);   % not(cellfun('isempty', regexpi(matpath,'tethys'))); 

filePath.all    = fName;
filePath.Tethys = fName(a,:);
filePath.Daphne = fName(b,:);
filePath.Makai  = fName(c,:);
logName.all     = logs;
logName.Tethys  = logs((a)==0,:);
logName.Daphne  = logs(a,:);

% Filter log paths and log-names for each vehicle
b = not(cellfun('isempty', regexpi(matpath,'daphne')));
c = not(cellfun('isempty', regexpi(matpath,'makai'))); 
a = ~(b | c);   % not(cellfun('isempty', regexpi(matpath,'tethys'))); 

matFilePaths.All     = matpath;
matFilePaths.Tethys  = matpath(a,:);
matFilePaths.Daphne  = matpath(b,:);
matFilePaths.Makai   = matpath(c,:);

matFileNames.All     = matname;
matFileNames.Tethys  = matname(a,:);
matFileNames.Daphne  = matname(b,:);
matFileNames.Makai   = matname(c,:);

end