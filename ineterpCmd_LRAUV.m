function [Cmd] = ineterpCmd_LRAUV(VerticalControl, newTimeGrid)

% ineterpCmd_LRAUV extract and interpulate

cmdf = {'elevatorAngleCmd','massPositionCmd','depthCmd','depthRateCmd',...
    'pitchCmd','pitchRateCmd','buoyancyCmd','speedCmd','elevatorAngleCmd',...
    'verticalMode'};

for k=1:numel(cmdf)
    if isfield(VerticalControl,cmdf{k})
        temp = VerticalControl.(cmdf{k}); % extract fixVars.
        temp.value = double(temp.value);  % prep data class for interp
        
        if numel(temp.value)>1
            % fix time and interpolate to new time grid
            [temp.time, temp.value] = fixTimeseries(temp.time, temp.value);
            Cmd.(cmdf{k}) = interp1(temp.time, temp.value, newTimeGrid,'nearest'); % <--!!!
        else
            warning(['VerticalControl.' cmdf{k} ': Record missing!'])
        end
    else
            warning(['VerticalControl.' cmdf{k} ': Record missing!'])    
    end
end