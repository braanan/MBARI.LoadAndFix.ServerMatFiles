% processLargeMAT_CRITICAL.m
% Last modified July 25, 2014
% Ben Raanan

% This script extracts only specific data (deignated in cell array
% varfields.mat) from large mat files located in a folder. It interpolates
% and saves parameters of interest to separate mat file. Originally written
% for shark attack data. Calls fixTimeseries.m

clear

% Connect to server or work locally (Passport)?
source='server.LRAUV'; % 'server.LRAUV' | 'server.900739' | 'local'
search = '201309121813_201309140344';
% Designat year of intrest: 
yr = 2013; % 2010 : 2014

% Vehicle of intrest: 
vc = 'Tethys'; % 'Tethys' | 'Daphne' | 'Makai' | 'All'->(server.900739 only)


workd = '~/Documents/MATLAB/MBARI/';
matf  = '/Volumes/Passport/MBARI/';
fname = which( 'processLargeMAT_CRITICAL.m' );

load varfields.mat

outmatf = [ matf num2str(yr) '/mat/workver/' ]; % shark/

% Load .mat file names and paths
%--------------------------------------------------------------------------
if strcmp(source,'server.LRAUV')
    
    [list,listf]  = findmat_LRAUV( vc, yr , search );


elseif strcmp(source,'server.900739')
    
%     load matFilePaths_900739_LRAUV_data.mat     % generated by: copy_CRITICAL.m
%     y = {['y' num2str(yr)]};
%     listf = matFileNames.(y{:});
%     list  = matFilePaths.(y{:});
   serverpath = '/Volumes/900739.LRAUV.data/Testing/'; 
   [ matFilePaths,matFileNames,~,~ ] = matFilePaths_900739_LRAUV_data( yr, serverpath );
   listf = matFileNames.(vc);
   list  = matFilePaths.(vc);
    
elseif strcmp(source,'local')
    
    inmatf = [ matf num2str(yr) '/mat/' ];                   % /Passport external drive
    
    % find .mat present in designated folder
    listDir = dir(inmatf);
    listf = {listDir(~[listDir.isdir]).name}'; 
    listf(not(cellfun('isempty', regexpi(listf,'.DS'))))=[];
    list  = strcat(repmat(inmatf,length(listf),1),listf);
end

% Extract specified varfields from .mat files and interp to fixed time-grid 
%--------------------------------------------------------------------------
for k = 1:length(list)
    % index file
    fileIndex = k;
    
    % gather info of mat file contents
    varlist = whos('-file',char(list(fileIndex)));
    varlistf = struct2cell(varlist); varlistf = varlistf(1,:)';
    
    
    % construct a variable index list for vars defiened in varfields
    varInt = zeros(size(varfields));
    
    for c=1:length(varfields)
        if sum(strcmp((varfields{c}),varlistf))~=0
            
            varInt(c) = find(strcmp((varfields{c}),varlistf)==1);
            
        else
            continue
        end
        %{
         % from before automation was written...
          varInt = [66, 67, 86, 91, 95, 96, 97, 98, 100, 101, 103, 111]; % for LRAUV_SIM.m
          varInt(3:end) = varInt(3:end) - 1;         % correct index for bottoming incedint
                                                     % mat file -> comment-out for
                                                     %             shark data!
        %}
        
    end; clear c
    varInt(varInt==0)=[];
    
    
    % load to struct
    if ~isempty(varInt)
        vars=load(char(list(fileIndex)),varlist(varInt).name);
    else
        continue
    end
    
    
    % extract cycle time-stamps and elevator servo offset angle
    ElevatorOffsetAngle = vars.ElevatorServo.offsetAngle;
    CycleStarter = vars.CycleStarter;
    vars = rmfield(vars,{'ElevatorServo','CycleStarter'});
    
    
    % make copy
    fixVars = vars;
    
    % list new variable names
    fields = fieldnames(fixVars);
    
    
    % get parameters on same time grid:
    tRes = 1/2.6; % sec, new time grid sampling rate 
    
    % create new time grid
    t1 = round2(min(CycleStarter.time.time),tRes/(3600*24)); % first time
    t2 = max(CycleStarter.time.time); % last time
    time=t1:tRes/(3600*24):t2; % new 1 sec grid
    
    % in some datasets time grids vectors are not strictly monotonic increasing
    % this loop fixes time vectoer and intrepolates data to new time grid
    for c = 1:numel(fields)
        
        % case VerticalControl struct (to get pitchCmd info)
        if strcmp('VerticalControl', fields{c})
            
            interpVars.Cmd = ineterpCmd_LRAUV(fixVars.(fields{c}), time);
          
        else
            temp = fixVars.(fields{c}); % extract
            % fix time and interpolate to new time grid
            if numel(temp.value)>1
                [temp.time, temp.value] = fixTimeseries(temp.time, temp.value);
                interpVars.(fields{c}) = interp1(temp.time, temp.value, time);
            else
                warning(['Log ' char(listf(fileIndex)) ': ' fields{c} ' record missing!']) 
            end
        end
    end; clear c temp
    
    % save
    %
    save([ outmatf 'LRAUV_SIM_' char(listf(fileIndex)) ],'vars','fixVars','interpVars',...
        'time','ElevatorOffsetAngle','CycleStarter');
    clear vars fixVars interpVars time
    %}
end
% save('~/Documents/MATLAB/MBARI/mat/varfields.mat', 'varfields')