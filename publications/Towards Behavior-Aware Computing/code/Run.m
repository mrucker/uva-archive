globals();

calls_windows_zero = 0;
calls_windows_not_zero = 0;

calls_zero = 0;
calls_not_zero = 0;

texts_windows_zero = 0;
texts_windows_not_zero = 0;

texts_zero = 0;
texts_not_zero = 0;
 
for userid = getUserIds()

    disp(userid);

    tic
    call_window_names = loadCallWindowNames(userid{1});
    text_window_names = loadTextWindowNames(userid{1});
    toc

    tic
    call_window_signals = loadCallWindowSignals(userid{1}, unique(vertcat(call_window_names{:})));
    text_window_signals = loadTextWindowSignals(userid{1}, unique(vertcat(text_window_names{:})));
    toc
    
    tic

    if ~isempty(call_window_signals) 
        calls_windows_zero     = calls_windows_zero + sum(cell2mat(values(call_window_signals)) == 0);
        calls_windows_not_zero = calls_windows_not_zero + sum(cell2mat(values(call_window_signals)) ~= 0);
        
        for windows = call_window_names
            if isempty(windows); continue; end
            
            windows        = windows{1}(isKey(call_window_signals, windows{1}));
            signals        = cell2mat(values(call_window_signals, windows));
            calls_zero     = calls_zero + all(signals == 0);
            calls_not_zero = calls_not_zero + any(signals ~= 0);
        end
    end

    if ~isempty(text_window_signals)
        texts_windows_zero     = texts_windows_zero + sum(cell2mat(values(text_window_signals)) == 0);
        texts_windows_not_zero = texts_windows_not_zero + sum(cell2mat(values(text_window_signals)) ~= 0);

        for windows = text_window_names
            if isempty(windows); continue; end

            windows        = windows{1}(isKey(text_window_signals, windows{1}));
            signals        = cell2mat(values(text_window_signals, windows));
            texts_zero     = texts_zero + all(signals == 0);
            texts_not_zero = texts_not_zero + any(signals ~= 0);
        end
    end
    toc
end

calls_windows_zero
calls_windows_not_zero

calls_zero
calls_not_zero

texts_windows_zero
texts_windows_not_zero

texts_zero
texts_not_zero

% all_full_data = [];
% all_full_lbls = [];
% all_call_data = [];
% all_call_lbls = [];
% all_text_data = [];
% all_text_lbls = [];

%all_call_tsne = tsne(all_call_data, 3, 20, 50, .5, 'svd');
%all_text_tsne = tsne(all_text_data, 3, 20, 50, .5, 'svd');
%all_full_tsne = tsne(all_full_data, 2, 20, 50, .5, 'svd');
%all_full_tsne = zeros(905566,3);

%save('../data/all_tsne_3d.mat', 'all_full_tsne', 'all_full_lbls', 'all_call_tsne', 'all_call_lbls', 'all_text_tsne', 'all_text_lbls');
%load('../data/all_tsne_2d.mat');

%plot_2d(all_call_tsne, all_call_lbls, 'call figure');
%plot_2d(all_text_tsne, all_text_lbls, 'text figure');
%plot_2d(all_full_tsne, all_full_lbls, 'full figure');

function userIds = getUserIds(); global CALL_SIGNAL_PATH TEXT_SIGNAL_PATH;
    userIds = vertcat(dir(CALL_SIGNAL_PATH), dir(TEXT_SIGNAL_PATH));
    userIds = unique({userIds.name});
    
    userIds = userIds(~strcmp(userIds, '.'));
    userIds = userIds(~strcmp(userIds, '..'));
end

function saveUserId(userid)
    userid = char(userid);

    if(any(strcmp(userid, {'.', '..'})))
        return;
    end
    
    if(userid == '.' || userid == '..')
        return;
    end
    
    userid = char(userid);
    
    [full_data, full_lbls] = loadData(userid, 0);
    [call_data, call_lbls] = partData('call', full_data, full_lbls);
    [text_data, text_lbls] = partData('text', full_data, full_lbls);

    call_lbls = strrep(call_lbls, ' text', '');
    text_lbls = strrep(text_lbls, ' call', '');

    save(['../data/' userid '/' userid '.mat'], 'full_data', 'full_lbls', 'call_data', 'call_lbls', 'text_data', 'text_lbls');
end

function [full_data, full_lbls, call_data, call_lbls, text_data, text_lbls] = loadUserId(userid)
    userid = char(userid);

    if(any(strcmp(userid, {'.', '..', 'all_tsne_2d.mat', 'all_tsne_3d.mat'})))
        full_data = [];
        full_lbls = [];
        call_data = [];
        call_lbls = [];
        text_data = [];
        text_lbls = [];
        return;
    end
    
    load(['../data/' userid '/' userid '.mat']);
end

function map = tsne(data, numDims, pcaDims, perplexity, theta, alg)
    disp('S Running');    
    map = fast_tsne(data, numDims, pcaDims, perplexity, theta, alg);
    disp('F Running');
end

function plot_2d(data, lbls, figureName)
    global SIAS;

    disp('S Plotting');
    tic
        ids = arrayfun(@(l) l{1}(1:4), lbls, 'UniformOutput', false);
    
        [h_data, ~] = partData(@(id) isKey(SIAS, id) && SIAS(id{1}) > 45, data, ids);
        [l_data, ~] = partData(@(id) isKey(SIAS, id) && SIAS(id{1}) < 38, data, ids);

        red   = [1 .5 .5];
        green = [.5 1 .5];

        figure('Name', figureName);
        hold on;

        plot(l_data(:,1), l_data(:,2), '.'...
             ,'MarkerSize'     , 5        ...
             ,'MarkerEdgeColor', green    ...
             ,'MarkerFaceColor', green    ...
             ,'DisplayName'    , 'low'    ...
        );
        
        plot(h_data(:,1), h_data(:,2), '.'...
             ,'MarkerSize'     , 4        ...
             ,'MarkerEdgeColor', red      ...
             ,'MarkerFaceColor', red      ...
             ,'DisplayName'    , 'high'   ...
        );
        
        [~,i,~,~] = legend('low', 'high', 'Location', 'northeast');
        
        i(4).MarkerSize = 15;
        i(6).MarkerSize = 15;
        
        hold off;
    toc
    disp('F Plotting');

end

function plot_3d(data, lbls, figureName)
    global SIAS;

    disp('S Plotting');
    tic
    
        ids = arrayfun(@(l) l{1}(1:4), lbls, 'UniformOutput', false);
        
        [h_data, ~] = partData(@(id) isKey(SIAS, id) && SIAS(id{1}) > 45, data, ids);
        [l_data, ~] = partData(@(id) isKey(SIAS, id) && SIAS(id{1}) < 28, data, ids);

        red   = [1 .5 .5];
        green = [.5 1 .5];

        figure('Name', figureName);
        hold on;

        plot3(l_data(:,1), l_data(:,2), l_data(:,3), '.'...
             ,'MarkerSize'     , 5                     ...
             ,'MarkerEdgeColor', green                 ...
             ,'MarkerFaceColor', green                 ...
             ,'DisplayName'    , 'low'                 ...
        );
        
        plot3(h_data(:,1), h_data(:,2), h_data(:,3), '.'...
             ,'MarkerSize'     , 4                     ...
             ,'MarkerEdgeColor', red                   ...
             ,'MarkerFaceColor', red                   ...
             ,'DisplayName'    , 'high'                ...
        );
        
        [~,i,~,~] = legend('low', 'high', 'Location', 'northeast');
        
        i(4).MarkerSize = 15;
        i(6).MarkerSize = 15;
        
        hold off;
    toc
    disp('F Plotting');

end

function [data, lbls] = loadData(user, obs_count)

    disp('S Loading')
    tic

    calls = loadCalls(user);
    texts = loadTexts(user);

    [data, lbls] = loadSignals(user, obs_count, calls, texts);
    
    toc
    disp('F Loading')

end

function [data, lbls] = partData(pred, all_data, all_lbls)
    indx = find(arrayfun(pred, all_lbls));
    data = all_data(indx, :);
    lbls = all_lbls(indx);
end

function [data, lbls] = loadSignals(user, obs_count, calls, texts); global SIGNAL_PATH;

    data = [];
    lbls = [];

    bins = -1:.1:1;
    paths  = filePaths([SIGNAL_PATH '/' user '/dyn_in/'], '*.mat');

    if(~exist('obs_count', 'var') || isnan(obs_count) || isempty(obs_count) || obs_count == 0)
        obs_count = length(paths);
    end
    
    for i = 1:obs_count
      window_datum = load(paths{i});
      window_datum = histcounts(window_datum.u{1}, bins);
      
      window_name  = regexp(paths{i},'win_\d+', 'match');
      window_name  = window_name{1};      
      
      window_label = string(user);
            
      if(sum(strcmp(calls, window_name)) > 0)
        window_label = strcat(window_label, ' call');
      end
      
      if(sum(strcmp(texts, window_name)) > 0)
        window_label = strcat(window_label, ' text');
      end

      data = [data; window_datum];
      lbls = [lbls; window_label];
    end

end

function calls = loadCalls(user); global CALL_PATH;    
    calls = [];

    for path = filePaths([CALL_PATH '/' user '/'], '*.txt')
      
      data  = importdata(char(path));
      
      if(~isempty(data))
        call  = strrep(data, '.csv', '');
        calls = [calls;call];
      end
    end
end

function texts = loadTexts(user); global TEXT_PATH;

    texts = [];

    for path = filePaths([TEXT_PATH '/' user '/'], '*.txt')
      
      data  = importdata(char(path));
      
      if(~isempty(data))
        text  = strrep(data, '.csv', '');
        texts = [texts;text];
      end
    end

end

function calls = loadCallWindowNames(user); global CALL_WINDOW_PATH;
    calls = cell(0,1);

    try
        cd([CALL_WINDOW_PATH '/' user '/']);

        for file = fileNames('*.txt')      
       
            try
                data  = importdata(file{1});

                  if(~isempty(data))
                    calls{end+1} = unique(strrep(strrep(data, '.csv,ahead', ''), '.csv,after', ''));
                  end
            catch
            end
            
        end
        
    catch
        disp(['non-existent user ' user])
    end
end

function texts = loadTextWindowNames(user); global TEXT_WINDOW_PATH;
    texts = cell(0,1);

    try
        cd([TEXT_WINDOW_PATH '/' user '/'])

        for file = fileNames('*.txt')
            try
              data  = importdata(file{1});

              if(~isempty(data))
                texts{end+1} = unique(strrep(strrep(data, '.csv,ahead', ''), '.csv,after', ''));
              end
            catch
            end
        end
    catch
        disp(['non-existent user ' user])
    end
end

function data = loadWindowSignals(user, windows); global SIGNAL_PATH;

    keys = cell(0,1);
    vals = cell(0,1);

    try
        cd([SIGNAL_PATH '/' user '/dyn_in/']);
        
        for file = fileNames('*.mat')

            window_name  = regexp(file{1},'win_\d+', 'match');
            window_name  = window_name{1};

            if(isempty(windows) || any(strcmp(windows, window_name)))
                try
                    window_datum = load(file{1});
                    window_datum = window_datum.u{1};

                    keys{end + 1} = window_name;
                    vals{end + 1} = sum(window_datum);
                catch
                end
            end
        end
    catch
        disp(['non-existent user ' user])
    end

    if ~isempty(keys) && ~isempty(vals)
        data = containers.Map(keys,vals);
    else
        data = [];
    end
end

function data = loadCallWindowSignals(user, windows); global CALL_SIGNAL_PATH;

    keys = cell(0,1);
    vals = cell(0,1);

    try
        cd([CALL_SIGNAL_PATH '/' user '/dyn_in/']);
        
        for file = fileNames('*.mat')

            window_name  = regexp(file{1},'win_\d+', 'match');
            window_name  = window_name{1};

            if ismember(window_name, windows) && ~ismember(window_name, keys)
                try
                    window_datum = load(file{1});
                    window_datum = window_datum.u{1};

                    keys{end + 1} = window_name;
                    vals{end + 1} = sum(window_datum);
                catch
                end
            end
        end               
    catch
        disp(['non-existent user ' user])
    end

    if ~isempty(keys) && ~isempty(vals)
        data = containers.Map(keys,vals);
    else
        data = [];
    end
end

function data = loadTextWindowSignals(user, windows); global TEXT_SIGNAL_PATH;

    keys = cell(0,1);
    vals = cell(0,1);

    try
        cd([TEXT_SIGNAL_PATH '/' user '/dyn_in/']);
        
        for file = fileNames('*.mat')

            window_name  = regexp(file{1},'win_\d+', 'match');
            window_name  = window_name{1};

            if ismember(window_name, windows) && ~ismember(window_name, keys)
                try
                    window_datum = load(file{1});
                    window_datum = window_datum.u{1};

                    keys{end + 1} = window_name;
                    vals{end + 1} = sum(window_datum);
                catch
                end
            end
        end        
    catch
        disp(['non-existent user ' user])
    end

    if ~isempty(keys) && ~isempty(vals)
        data = containers.Map(keys,vals);
    else
        data = [];
    end
end

function data = loadCallSignals(user)

    data = zeros(0,1);

    try
        cd(['C:/Users/mark.rucker/Desktop/mark/workshop/lds_output_call/lds_output_call' '/' user '/dyn_in/']);

        for file = fileNames('*.mat')

            window_datum = load(file{1});
            window_datum = window_datum.u{1};

            data(end + 1) = sum(window_datum);

        end
    catch
        disp(['non-existent user ' user])
    end    

end

function data = loadTextSignals(user)

    data = zeros(0,1);

    try
        cd(['C:/Users/mark.rucker/Desktop/mark/workshop/lds_output_text/lds_output_text' '/' user '/dyn_in/']);

        for file = fileNames('*.mat')

            window_datum = load(file{1});
            window_datum = window_datum.u{1};

            data(end + 1) = sum(window_datum);

        end
    catch
        disp(['non-existent user ' user])
    end

end

function file_paths = filePaths(folder, pattern)
    file_infos = dir([folder pattern]);    
    file_paths = strcat(folder, string({file_infos.name}));    
end

function file_names = fileNames(pattern)
    file_infos = dir(pattern);    
    file_names = {file_infos.name};
end

function globals(); global SIAS CALL_WINDOW_PATH TEXT_WINDOW_PATH SIGNAL_PATH CALL_SIGNAL_PATH TEXT_SIGNAL_PATH;

    CALL_WINDOW_PATH = 'C:/Users/mark.rucker/Desktop/mark/workshop/call_window_list_2min/call_window_list_2min';
    TEXT_WINDOW_PATH = 'C:/Users/mark.rucker/Desktop/mark/workshop/text_window_list_2min/text_window_list_2min';
    SIGNAL_PATH      = '';
    CALL_SIGNAL_PATH = 'C:/Users/mark.rucker/Desktop/mark/workshop/lds_output_call/lds_output_call';
    TEXT_SIGNAL_PATH = 'C:/Users/mark.rucker/Desktop/mark/workshop/lds_output_text/lds_output_text';

    keys = {'1000', '1001', '1002', '1003', '1004', '1005', '1047', '1048', '1078', '1079', '1080', '1081', '1082', '1083', '1084', '1085', '1086', '1087', '1088', '1089', '1090', '1091', '1092', '2003', '2004', '2005', '2006', '2007', '2008', '2009', '2011', '2012', '2013', '2014', '2015', '2016', '2017', '2018', '2019', '2020', '2021', '2022', '2023', '2024', '2025', '2026', '2027', '2028', '2029', '2037', '2047', '2048', '2049', '2050', '2051', '2084', '2085', '2086', '2087', '2088', '2089', '2090', '2091', '2092', '2093', '2094', '2095', '2096', '2097', '2098', '2099'};
    vals = [11, 42, 37, 28, 14, 39, 19, 29, 48, 39, 50, 35, 49, 33, 39, 35, 32, 54, 55, 66, 36, 50, 39, 43, 21, 48, 27, 36, 20, 43, 23, 33, 25, 36, 17, 15, 45, 18, 29, 28, 31, 28, 21, 22, 28, 30, 25, 26, 32, 22, 20, 36, 47, 43, 48, 44, 52, 61, 68, 51, 42, 61, 42, 34, 44, 39, 36, 36, 43, 44, 50];

    SIAS = containers.Map(keys,vals);
end