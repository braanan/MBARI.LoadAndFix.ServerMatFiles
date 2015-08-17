% process_CRITICAL.m
% Last modified June 19, 2014
% Ben Raanan

% This script plots mission data for first glans and saves parameters of 
% interest to separate mat file

clear all;

workd='~/Documents/MATLAB/MBARI/';
fname=which('process_CRITICAL.m');

% year of interest
yr=2013;
df=['/Volumes/Passport/MBARI/' num2str(yr) '/mat/shark/'];
% find .mat already present in folder
listDir = dir(df);
list = {listDir(~[listDir.isdir]).name}';

% load .mat
load([df char(list)])

%
figure;
subplot(3,1,1)
plot(depth.time,depth.value)
set(gca,'YDir','reverse');
ylabel('Depth (m)')
xnum=get(gca,'xtick');
set(gca,'xtick',xnum,'xticklabel',datestr(xnum,'mmm-dd'));

subplot(3,1,2)
plot(platform_pitch_angle.time,platform_pitch_angle.value)
set(gca,'YDir','reverse');
ylabel('rad')
xnum=get(gca,'xtick');
set(gca,'xtick',xnum,'xticklabel',datestr(xnum,'mmm-dd'));

subplot(3,1,3)
plot(platform_speed_wrt_propeller.time,platform_speed_wrt_propeller.value)
% platform_speed_wrt_propeller
set(gca,'YDir','reverse');
ylabel('m/s')
xnum=get(gca,'xtick');
set(gca,'xtick',xnum,'xticklabel',datestr(xnum,'mmm-dd'));
uicontrol('Style', 'text','String', fname,...
    'Units','normalized',...
    'Position', [0 0 1 0.025]);

figure;
hist(platform_speed_wrt_propeller.value,100)
%}
% extract some parameters to work with
save([df 'workver/wv_' char(list(14))],'depth','platform_pitch_angle',...
    'platform_speed_wrt_propeller','depth_rate');
