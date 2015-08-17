% findmat_CRITICAL.m
% Last modified June 19, 2014
% Ben Raanan

clear all;

workd = '~/Documents/MATLAB/MBARI/';

% years of interest
yr=2010:2014;
vol='/Volumes';

for n=4 %1:length(yr)
    
    load([workd 'mat/' num2str(yr(n)) '-int-CRITICAL.mat']);
       
    for j=1:length(pathFilt);
        
        % edit pathFilt
        pWork=char(pathFilt(j));
        slash=strfind(pWork,'/');
        pWork=pWork(slash(2):end); 
        
        % find folders w/ .mat files and log paths
        list=ls([vol pWork]);
        mat=strfind(list,'.mat');
        
        if isempty(mat)~=1
            hasMATfile(j,:)=1;
            matPath(j,:)=cellstr(list(mat(1)-25:mat(1)+3))
        else
            hasMATfile(j,:)=0;
        end
      
        strsplit(list,' ')
        pathFilt(j,:)=cellstr(pWork);
    end; clear j list slash mat;
 
% save
%{
save([workd 'mat/' num2str(yr(n)) '-int-CRITICAL_corectPath.mat'],...
    'cName','comp','compFilt','compHeader','impLog','path','pathFilt',...
    'timeFilt','timeLog','hasMATfile');
%}
% clear hasMATfile pathFilt
end; 