users = ['1000'; '1001'; '1002'; '1003'; '1004'; '1005'; '1047'; '1048'; '1049'; '1078'; '1079'; '1080'; '1081'; '1083'; '1084'; '1085'; '1087'; '1088'; '1090'; '1091'; '2003'; '2004'; '2006'; '2007'; '2008'; '2009'; '2012'; '2014'; '2015'; '2016'; '2017'; '2018'; '2019'; '2020'; '2021'; '2022'; '2023'; '2024'; '2025'; '2026'; '2027'; '2028'; '2029'; '2037'; '2047'; '2048'; '2049'; '2050'; '2051'; '2084'; '2085'; '2086'; '2087'; '2088'; '2089'; '2090'; '2091'; '2092'; '2093'; '2094'; '2095'; '2096'; '2097'; '2098'; '2099'];

for user = users
    values = Values(user);
end

function out = Values(user)
    root_path='C:\Users\mark.rucker\Projects\mr2an\publications\Towards Behavior-Aware Computing\data\sms\';

    sms_path  = [root_path 'output_sms_long\output_sms_long\'];

    sms_file  = ['sms_'  user '.csv'];

    sms_vals  = csvread([sms_path sms_file], 1, 0);

    sms_d = datenum(datetime(sms_vals(:,1)/1000, 'ConvertFrom', 'posixtime')).';

    out = horzcat(sms_vals, sms_d);

end