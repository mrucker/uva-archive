global ROOT USERS; 

ROOT  = 'C:\Users\mark.rucker\Projects\mr2an\publications\Towards Behavior-Aware Computing\data';
USERS = ['1000'; '1001'; '1002'; '1003'; '1004'; '1005'; '1047'; '1048'; '1049'; '1078'; '1079'; '1080'; '1081'; '1083'; '1084'; '1085'; '1087'; '1088'; '1090'; '1091'; '2003'; '2004'; '2006'; '2007'; '2008'; '2009'; '2012'; '2014'; '2015'; '2016'; '2017'; '2018'; '2019'; '2020'; '2021'; '2022'; '2023'; '2024'; '2025'; '2026'; '2027'; '2028'; '2029'; '2037'; '2047'; '2048'; '2049'; '2050'; '2051'; '2084'; '2085'; '2086'; '2087'; '2088'; '2089'; '2090'; '2091'; '2092'; '2093'; '2094'; '2095'; '2096'; '2097'; '2098'; '2099'];

Run();

function Run(); global USERS;
    for user = USERS.'
        values = ReadValues(user.');

        grp_dt = cell(0);
        grp_sz = cell(0);
        grp_id = 1;

        if(~isempty(values))
            grp_dt{grp_id} = datetime(values(1), 'ConvertFrom', 'datenum');
            grp_sz{grp_id} = 1;

            for i = 1:length(values)-1

                if(etime(datevec(values(i+1)), datevec(values(i))) < 600)
                    grp_sz{grp_id} = grp_sz{grp_id} + 1;
                else
                    grp_id = grp_id + 1;

                    grp_dt{grp_id} = datetime(values(i+1), 'ConvertFrom', 'datenum');
                    grp_sz{grp_id} = 1;
                end
            end
        end

        WriteValues(user.', grp_sz, grp_dt);
    end
end

function values = ReadValues(user); global ROOT;

    ME = [];
    fid = fopen([ROOT '\in\' 'sms_'  user '.csv']);

    try        
        values = textscan(fid, '%s %s %f %s %s', 'HeaderLines', 1, 'Delimiter', ',');
        values = datenum(datetime(values{3}/1000, 'ConvertFrom', 'posixtime')).';
    catch ME
    end

    fclose(fid);

    if ~isempty(ME)
        rethrow(ME);
    end
end

function WriteValues(user, grp_sz, grp_dt); global ROOT;

    ME = [];
    fid = fopen([ROOT '\out\' 'sms_'  user '.csv'], 'w');

    try
        fprintf(fid, 'Text Group Size, Text Group Start\r\n');

        for i = 1:length(grp_sz)
            fprintf(fid, [num2str(grp_sz{i}) ',' datestr(grp_dt{i}) '\r\n']);
        end
    catch ME
    end

    fclose(fid);

    if ~isempty(ME)
        rethrow(ME);
    end
end
