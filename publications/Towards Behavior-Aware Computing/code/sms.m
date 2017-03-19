global ROOT USERS; 

ROOT  = '.';
USERS = ['1000'; '1001'; '1002'; '1003'; '1004'; '1005'; '1047'; '1048'; '1049'; '1078'; '1079'; '1080'; '1081'; '1083'; '1084'; '1085'; '1087'; '1088'; '1090'; '1091'; '2003'; '2004'; '2006'; '2007'; '2008'; '2009'; '2012'; '2014'; '2015'; '2016'; '2017'; '2018'; '2019'; '2020'; '2021'; '2022'; '2023'; '2024'; '2025'; '2026'; '2027'; '2028'; '2029'; '2037'; '2047'; '2048'; '2049'; '2050'; '2051'; '2084'; '2085'; '2086'; '2087'; '2088'; '2089'; '2090'; '2091'; '2092'; '2093'; '2094'; '2095'; '2096'; '2097'; '2098'; '2099'];

Run();

function Run(); global USERS;
    for user = USERS.'
        [values, dates] = ReadValues(user.');

        groups = zeros(numel(dates), 1);
        grp_id = 1;

        for i = 1:numel(dates)

            groups(i) = grp_id;

            if(i < numel(dates) && etime(datevec(dates(i+1)), datevec(dates(i))) > 600)
                grp_id = grp_id + 1;
            end
        end

        WriteValues(user.', values, groups);
    end
end

function [values, dates] = ReadValues(user); global ROOT;

    ME = [];
    fid = fopen([ROOT '\in\' 'sms_'  user '.csv']);

    try        
        values = textscan(fid, '%s %s %f %s %s', 'HeaderLines', 1, 'Delimiter', ',');
        dates  = datenum(datetime(values{3}/1000, 'ConvertFrom', 'posixtime'));
    catch ME
    end

    fclose(fid);

    if ~isempty(ME)
        rethrow(ME);
    end
end

function WriteValues(user, values, groups); global ROOT;

    ME = [];
    fid = fopen([ROOT '\out\' 'sms_'  user '.csv'], 'w');
    
    try
        fprintf(fid, 'PID,Date,Date_long,FromNumber,ToNumber,Group\r\n');

        for i = 1:numel(groups)
            fprintf(fid, [values{1}{i} ',' values{2}{i} ',' num2str(values{3}(i)) ',' values{4}{i} ',' values{5}{i} ',' num2str(groups(i)) '\r\n']);
        end
    catch ME
    end

    fclose(fid);

    if ~isempty(ME)
        rethrow(ME);
    end
end