%% getVARData.m 
% getVARData.m is a matlab script that will pull the data for the VAR model
% that forecasts much of the macro-economy aggregates for surveys like the
% SPF and WSJ surveys of professional economists. 
%
%
%      % Butters (2024)
%
%

clear; close all; clc;

%% Define data series and other particulars

startDate   = datetime(1975,3,31);
seriesNames = {'GS10';     % Treasury notes, 10-year
               'TB3MS';    % T-Bill Rate, 3-month yields
               'AAA';      % AAA Corp Bond Yield
               'BAA';      % BAA Corp Bond Yield
               'FEDFUNDS'; % Fed Funds Rate
               'GDPC1';    % Real GDP
               'PCECC96';  % Real Personal Consumption Expenditures
               'PNFIC1';   % Real non-residential fixed investment
               'PRFIC1';   % Real residential fixed investment 
               'SLCEC1';   % Real state and local government consumption/gross investment
               'CBIC1';    % Real change in inventories
               'EXPGSC1';  % Real exports of goods and services
               'IMPGSC1';  % Real imports of goods and services
               'CP';       % Corporate profits
               'INDPRO';   % Industrial production
               'HOUST';    % Housing starts 
               'USSTHPI';  % FHFA U.S. total house price index
               'UNRATE';   % Unemployment rate
               'PAYEMS';   % Total payroll employment 
               'GDPCTPI';  % GDP price index
               'CPIAUCSL'; % Consumer price index
               'CPILFESL'; % Core consumer price index
               'PCECTPI';  % PCE price index
               'PCEPILFE'; % Core PCE price index
               'GDP'};     % Nominal GDP

%% Loop through each series and pull from FRED (St. Louis Fed database)

% pre-allocate datatable
data_table = timetable; 

for jj = 1:length(seriesNames)
    % open fred database, and fetch series
    c = fred;
    d = fetch(c,seriesNames(jj));
    close(c)
    
    % convert to quarterly time frequency
    d_q = convert2quarterly(timetable(datetime(datestr(d.Data(:,1))),d.Data(:,2)),'Aggregation','mean');
    
    % save new variable in workspace
    eval(['d_q.Properties.VariableNames = {''' seriesNames{jj} '''};'])
    eval([seriesNames{jj} ' = d_q;'])

    % append data series to data_table
    eval(['data_table = synchronize(data_table,' seriesNames{jj} ');'])
end

data_table.Time = datetime(data_table.Time,'Format','QQQ-yyyy');
startPos        = find(startDate==data_table.Time);
data_table      = data_table(startPos:end,:); 

%% Output raw data to .csv file for archival purposes 

writetimetable(data_table,'raw_data.csv')

%% End of file