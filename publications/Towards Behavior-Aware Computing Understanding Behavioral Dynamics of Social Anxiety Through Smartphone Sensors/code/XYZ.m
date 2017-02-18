user = '1001';

root_path='C:\Users\mark.rucker\Projects\accelerometer\data_for_diagram\data_for_diagram\';

acc_path  = [root_path 'output_acc_long_addgap\output_acc_long_addgap\'];
call_path = [root_path 'output_call_long_real\output_call_long_real\'];
sms_path  = [root_path 'output_sms_long\output_sms_long\'];

acc_file  = ['acc_'  user '.csv'];
call_file = ['call_' user '.csv'];
sms_file  = ['sms_'  user '.csv'];

acc_vals  = csvread([acc_path acc_file], 1, 0);
call_vals = csvread([call_path call_file], 1, 0);
sms_vals  = csvread([sms_path sms_file], 1, 0);

ds = datenum(datetime(acc_vals(:,1)/1000, 'ConvertFrom', 'posixtime'));

acc_x = acc_vals(:,2);
acc_y = acc_vals(:,3);
acc_z = acc_vals(:,4);
acc_m = {'X', 'Y', 'Z'; acc_x, acc_y, acc_z};

call_s = datenum(datetime(call_vals(:,1)/1000, 'ConvertFrom', 'posixtime'));
call_f = datenum(datetime(call_vals(:,2)/1000, 'ConvertFrom', 'posixtime'));
call_m = [call_s.';call_f.'];

sms_d = datenum(datetime(sms_vals(:,1)/1000, 'ConvertFrom', 'posixtime')).';

min_x = min(ds);
max_x = addtodate(min_x, 2, 'day');
tick_ind = 0:4;
tick_stp = (max_x - min_x)/(length(tick_ind)-1);
tick_loc = min_x + (tick_ind*tick_stp);
position = [100, 200, 1068, 69];

for i = acc_m    
    name = i{1};
    vals = i{2};
    
    figure('Name', [name '-Axis'], 'Color', [1 1 1], 'Position', position)
    plot(ds, vals, 'DisplayName', [name '-Magnitude'])
    xlim([min_x max_x])
    ylim([-50 50])
    xticks(tick_loc)    
    datetick('x', 'mm/dd HH:MM', 'keepticks', 'keeplimits')
    %lgd = legend('show');
    %lgd.FontSize = 12;
end

figure('Name', 'Call-Text', 'Color', [1 1 1], 'Position', position)
plot(ds, acc_z+100, 'DisplayName', 'Z-Magnitude')
hold on;
for i = call_m
r = rectangle('Position', [i(1) 0 i(2)-i(1) 1], 'FaceColor', [0 .75 0], 'EdgeColor', [0 .75 0]);
end
for i = sms_d
l = line([i i], [0 1], 'Color', [.75 0 .75]);
end

xlim([min_x max_x])
ylim([0 1])
xticks(tick_loc)
yticks(100)
datetick('x', 'mm/dd HH:MM', 'keepticks', 'keeplimits')

pr = plot(nan,nan,'color',get(r,'facecolor'));
pl = plot(nan,nan,'color',get(l,'color'));

%lgd = legend([pr pl], 'Calls', 'Texts');
%lgd.FontSize = 12;
hold off;