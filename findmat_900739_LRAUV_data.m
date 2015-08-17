% findmat_900739_LRAUV_data.m
% Last modified Dec 22, 2014
% Ben Raanan

% This script checks log folders on the server for .mat files (not all of 
% them have them) and logs file name and path

clear 

workd = '~/Documents/MATLAB/MBARI/';

% years of interest
yr=2010:2014;
vol='/Volumes';

for n=1:length(yr)
    
    load([workd 'mat/' num2str(yr(n)) '-int-CRITICAL.mat']);
    
    hasMATfile=NaN(size(pathFilt));
    for j=1:length(pathFilt);
        
        % edit pathFilt
        pWork=char(pathFilt(j));
        slash=strfind(pWork,'/');
        pWork=pWork(slash(2):end);
        
        % find folders w/ .mat files and log paths
        list=ls([vol pWork]);
        mat=strfind(list,'.mat');
        
        % eliminate flagged .mat files that don't match desired file name 
        % format (yyyymmddhhmm_yyyymmddhhmm.mat)
        if ~isempty(mat)
            matfn=list(mat(1)-25:mat(1)+3);
            if length(strfind(matfn,num2str(yr(n))))~=2
                mat=[];
                matfn=[];
            end
        end
        
        % log
        if isempty(mat)~=1
            hasMATfile(j,:)=1;
            matPath(j,:)=cellstr(matfn);
        else
            hasMATfile(j,:)=0;
            matPath(j,:)=cellstr('empty');
        end
        
        pathFilt(j,:)=cellstr(pWork);
        
    end; clear j list slash mat matfn pWork;
    
    compFilt(:,10)=matPath;
    compHeader{10}='.mat filename';
    
    % save
    %
    save([workd 'mat/' num2str(yr(n)) '-int-CRITICAL.mat'],...
        'cName','comp','compFilt','compHeader','impLog','path','pathFilt',...
        'timeFilt','timeLog','hasMATfile','matPath');
    %}
    clear hasMATfile pathFilt matPath
end;