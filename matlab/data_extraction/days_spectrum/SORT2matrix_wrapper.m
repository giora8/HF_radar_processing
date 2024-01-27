addpath(genpath('..\..\'));

config = jsondecode(fileread('run_config.json'));
days = string(configData.extraction_configuration.days_to_analyze);

for ii = 1 : length(days)
    sprintf('Starting day: %d out of %d', ii, length(days))
    SORT2matrix(config, days(ii));
end
