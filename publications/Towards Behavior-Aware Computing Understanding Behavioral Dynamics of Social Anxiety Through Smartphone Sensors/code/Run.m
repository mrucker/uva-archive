globals();
% all_full_data = [];
% all_full_lbls = [];
% all_call_data = [];
% all_call_lbls = [];
% all_text_data = [];
% all_text_lbls = [];
% 
% for userid = getUserIds()
%     [usr_full_data, usr_full_lbls, usr_call_data, usr_call_lbls, usr_text_data, usr_text_lbls] = loadUserId(userid);
%     
%     all_full_data = [all_full_data;usr_full_data];
%     all_full_lbls = [all_full_lbls;usr_full_lbls];
%     all_call_data = [all_call_data;usr_call_data];
%     all_call_lbls = [all_call_lbls;usr_call_lbls];
%     all_text_data = [all_text_data;usr_text_data];
%     all_text_lbls = [all_text_lbls;usr_text_lbls];
% end

%all_call_tsne = tsne(all_call_data, 3, 20, 50, .5, 'svd');
%all_text_tsne = tsne(all_text_data, 3, 20, 50, .5, 'svd');
%all_full_tsne = tsne(all_full_data, 2, 20, 50, .5, 'svd');
%all_full_tsne = zeros(905566,3);

%save('../data/all_tsne_3d.mat', 'all_full_tsne', 'all_full_lbls', 'all_call_tsne', 'all_call_lbls', 'all_text_tsne', 'all_text_lbls');
load('../data/all_tsne_2d.mat');

plot_2d(all_call_tsne, all_call_lbls, 'call figure');
plot_2d(all_text_tsne, all_text_lbls, 'text figure');
plot_2d(all_full_tsne, all_full_lbls, 'full figure');

function userIds = getUserIds()
    userIds = dir('../data/');
    userIds = string({userIds.name});
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

function [data, lbls] = loadSignals(user, obs_count, calls, texts)

    data = [];
    lbls = [];

    bins = -1:.1:1;
    paths  = filePaths(['../data/' user '/signals/'], '*.mat');

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

function calls = loadCalls(user)
    calls = [];

    for path = filePaths(['../data/' user '/calls/'], '*.txt')
      call  = strrep(importdata(char(path)), '.csv', '');
      calls = [calls;call];
    end

end

function texts = loadTexts(user)

    texts = [];

    for path = filePaths(['../data/' user '/texts/'], '*.txt')
      text  = strrep(importdata(char(path)), '.csv', '');
      texts = [texts;text];
    end

end

function file_paths = filePaths(folder, pattern)
    file_infos = dir([folder pattern]);    
    file_paths = strcat(folder, string({file_infos.name}));    
end

function globals()
    global SIAS;
        
    keys = {'1000', '1001', '1002', '1003', '1004', '1005', '1047', '1048', '1078', '1079', '1080', '1081', '1082', '1083', '1084', '1085', '1086', '1087', '1088', '1089', '1090', '1091', '1092', '2003', '2004', '2005', '2006', '2007', '2008', '2009', '2011', '2012', '2013', '2014', '2015', '2016', '2017', '2018', '2019', '2020', '2021', '2022', '2023', '2024', '2025', '2026', '2027', '2028', '2029', '2037', '2047', '2048', '2049', '2050', '2051', '2084', '2085', '2086', '2087', '2088', '2089', '2090', '2091', '2092', '2093', '2094', '2095', '2096', '2097', '2098', '2099'};
    vals = [11, 42, 37, 28, 14, 39, 19, 29, 48, 39, 50, 35, 49, 33, 39, 35, 32, 54, 55, 66, 36, 50, 39, 43, 21, 48, 27, 36, 20, 43, 23, 33, 25, 36, 17, 15, 45, 18, 29, 28, 31, 28, 21, 22, 28, 30, 25, 26, 32, 22, 20, 36, 47, 43, 48, 44, 52, 61, 68, 51, 42, 61, 42, 34, 44, 39, 36, 36, 43, 44, 50];

    SIAS = containers.Map(keys,vals);    
end