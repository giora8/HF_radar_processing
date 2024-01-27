addpath(genpath('..\..\'));

try
    config = jsondecode(fileread('../../../run_config.json'));
catch
    config = jsondecode(fileread('run_config.json'));
end
days = string(config.extraction_configuration.days_to_analyze);

for ii = 1 : length(days)
    sprintf('Starting day: %d out of %d', ii, length(days))
    SORT2matrix(config, days(ii));
end
