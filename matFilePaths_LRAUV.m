function [ LRAUVmatFiles ] = matFilePaths_LRAUV( serverpath,varargin )

% This function locates .mat files from server folders and logs thier paths
% Last modified Dec. 22, 2014
% Ben Raanan

% INPUTS:
% serverpath = '/Volumes/LRAUV';
outputfolder = ([fileparts(which('matFilePaths_LRAUV.m')) filesep 'mat' filesep]);
vh = { 'Tethys', 'Daphne', 'Makai'} ; % (e.g., 'Tethys','Daphne','Makai')
yr = 2010:2015; % (e.g., 2010,2011,...,2015)
%--------------------------------------------------------------------------


% Load old scans
%------------------------------------------------------------------
try
    load([outputfolder 'LRAUVmatFiles.mat']);
    oldscan = LRAUVmatFiles;
catch
    oldscan = [];
    warning('Couldnt find LRAUVmatFiles.mat: Performing full scan')
end


% Force fresh scan
if strcmpi(varargin,'fresh')
    oldscan = [];
end

% define nonrelevent directories
ignore  = {' ';'.';'..';'latest';'Lab';'Tank';'Tow';'Battery'};


for v=1:numel(vh)
    
    for q=1:numel(yr)
        
        % Server path structure
        pathFolder = [serverpath filesep vh{v} filesep 'missionlogs' filesep num2str(yr(q)) filesep];
        
        
        % find folder subdirectories
        %------------------------------------------------------------------
        d = dir(pathFolder);
        isub = [d(:).isdir]; %# returns logical vector
        nameFolds = {d(isub).name}';
        
        
        % compare to older scans and eliminate nonrelevent directories
        %------------------------------------------------------------------
        if ~isempty(oldscan)
            
            oldpaths = oldscan.(vh{v}).logName.(['y' num2str(yr(q))])(:,1);
            oldpaths = unique(oldpaths);
            
            nameFolds = setdiff(nameFolds,oldpaths);
            clear oldpaths
        end
        
        % eliminate other nonrelevent directories
        [~,ci] = ispresent(nameFolds,ignore);
        nameFolds = nameFolds(~ci);
        clear ci
        
        
        
        
        % GET .MAT FILES FROM SERVER
        %------------------------------------------------------------------
        fName = cell(1);
        logs  = cell(1,3);
        matpath = cell(1,2);
        matname = cell(1); matCount = 0;
        if ~(cellfun('isempty',nameFolds))
            for j=1:numel(nameFolds)
                
                % folder path
                tmp = [pathFolder nameFolds{j} filesep];
                
                % readin .dlist
                mname = cell(1);
                fileID = fopen([pathFolder nameFolds{j} '.dlist']);
                if fileID~=-1
                    txt = textscan(fileID,'%s','Delimiter', '\n');
                    dlist = txt{1,1};
                    
                    if ~isempty(dlist)
                        ci = ~(cellfun('isempty', strfind(dlist,'Deployment Name:')));
                        mname = char(dlist(ci,1));
                        mname = mname(20:end);
                    end
                    fclose(fileID);
                end; clear fileID txt dlist ci
                
                
                % find folder subdirectories
                d = dir(tmp);
                isub = [d(:).isdir];       %# returns logical vector
                X = {d(isub).name}';
                
                % eliminate nonrelevent directories
                ci = ~cellfun('isempty', strfind(X,num2str(yr(q))));
                X = X(ci);
                
                % log names
                in = size(fName,1)+1;
                ind = in:length(X)+in-1;
                logs(ind,2) = X;
                
                % concatanate to form .mat file paths
                for k=1:length(ind)
                    logs{ind(k),1} = nameFolds{j};
                    fName{ind(k),:} = strcat(tmp,X{k},filesep);
                    
                    % locate relevant .mat files within each log
                    w = what(fName{ind(k)});
                    m1 = ~cellfun('isempty',regexp(w.mat, ['^' num2str(yr(q))]));
                    m2 = cellfun('length', w.mat)==29; % make sure its the full dataset
                    logs{ind(k),3} = w.mat(m1 & m2);   % and not science_...
                    
                    
                    % log relevant .mat files paths and names
                    for m = 1:numel(logs{ind(k),3})
                        matCount = matCount+1;
                        tmpmat=logs{ind(k),3};
                        matpath{matCount,1} = mname;
                        matpath{matCount,2} = strcat(fName{ind(k),:},tmpmat{m});
                        matname{matCount,:} = tmpmat{m};
                    end; clear m
                end; clear k;
            end; clear j in ind isub d ci X;
            fName(1) =[];
            logs(1,:)=[];
        end
        
        % Reorganize to output struct
        %------------------------------------------------------------------
        if any(~cellfun('isempty',fName))
            if ~isempty(oldscan)
                LRAUVmatFiles.(vh{v}).filePath.(['y' num2str(yr(q))]) = [LRAUVmatFiles.(vh{v}).filePath.(['y' num2str(yr(q))]); fName];
            else
                LRAUVmatFiles.(vh{v}).filePath.(['y' num2str(yr(q))]) = fName;
            end
        end
        if any(any(~cellfun('isempty',logs)))
            if ~isempty(oldscan)
                LRAUVmatFiles.(vh{v}).logName.(['y' num2str(yr(q))]) = [LRAUVmatFiles.(vh{v}).logName.(['y' num2str(yr(q))]); logs];
            else
                LRAUVmatFiles.(vh{v}).logName.(['y' num2str(yr(q))]) = logs;
            end
        end
        if any(any(~cellfun('isempty',matpath)))
            if ~isempty(oldscan)
                LRAUVmatFiles.(vh{v}).matFilePaths.(['y' num2str(yr(q))]) = [LRAUVmatFiles.(vh{v}).matFilePaths.(['y' num2str(yr(q))]); matpath];
            else
                LRAUVmatFiles.(vh{v}).matFilePaths.(['y' num2str(yr(q))]) = matpath;
            end
        end
        if any(~cellfun('isempty',matname))
            if ~isempty(oldscan)
                LRAUVmatFiles.(vh{v}).matFileNames.(['y' num2str(yr(q))]) = [LRAUVmatFiles.(vh{v}).matFileNames.(['y' num2str(yr(q))]); matname];
            else
                LRAUVmatFiles.(vh{v}).matFileNames.(['y' num2str(yr(q))]) = matname;
            end
        end
    end
end

% save
%
% uisave('LRAUVmatFiles','LRAUVmatFiles.mat')
save([outputfolder 'LRAUVmatFiles.mat'],...
    'LRAUVmatFiles');
%}
end
