% copy_CRITICAL.m
% Last modified June 19, 2014
% Ben Raanan

% This script copys .mat files from server to local drive in bulk

clear

workd = '~/Documents/MATLAB/MBARI/';
vol='/Volumes';
serverpath = '/Volumes/900739.LRAUV.data/Testing/';

% years of interest
yr=2010:2014;
y = {'y2010','y2011','y2012','y2013','y2014'};

% Copy .mat files to drive? (Y=1)
copyMat=0;



for k=1:length(yr)
    clearvars -except copyMat workd vol yr y k matFilePaths matFileNames

    % load
    load([workd 'mat/' num2str(yr(k)) '-int-CRITICAL.mat']);
    clear impLog path comp timeLog;
    
    [ matPath, filePath, logName ] = findLogPathLRAUV( yr(k), serverpath );
    
    
    % reduce .mat list
    uni=unique(matPath);
    uni(ismember(uni,'empty'))=[];
    
    if copyMat==1
        % find .mat already present in folder
        listDir = dir([vol '/Passport/MBARI/' num2str(yr) '/mat/']);
        list = {listDir(~[listDir.isdir]).name};
        
        % eliminate files already copied from queue list
        c=1;
        for n=1:length(uni)
            if sum(strcmp(uni(n), list))==0
                u(c,1)=uni(n);
                c=c+1;
            end
        end; clear n c;
    else
        u=uni;
    end
    
   
    for c=1:length(u)
        mp=char(u(c));
        f=find(ismember(matPath,mp),1);
        
        matFilePaths.(y{k}){c,:} = [vol char(pathFilt(f)) mp];
        matFileNames.(y{k}){c,:} = mp;
        
        % copy files from server to drive
        % restrict to files under 3gb
        if copyMat==1
            s=dir([vol char(pathFilt(f)) mp]);
            if s.bytes/(1e9)<=3
                display([mp ' file size: ' num2str(s.bytes/(1e9)) 'gb']);
                copyfile([vol char(pathFilt(f)) mp],[vol '/Passport/MBARI/' num2str(yr) '/mat/'])
            else
                warning([vol char(pathFilt(f)) mp ' not copied: file size(' num2str(s.bytes/(1e9)) 'gb)'])
            end
        end
        
        clear mp
    end
end

% save .mat file paths
%{
save([workd 'mat/matFilePaths_900739_LRAUV_data.mat'],...
'matFilePaths','matFileNames')
%}
