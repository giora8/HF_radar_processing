%% points_of_interest_plot.m
function points_of_interest_plot(locs, col, m_type)
%% Inputs
%  locs = 2D array of single point location as (longitude, latitude) - N X 2
%
%% Output
%  current axes is updated with the locations specified in locs
%
% -------------------------------------------------------------------------

    for cur_plot = 1 : size(locs, 1)
        if nargin == 1
            hold on; plot(locs(cur_plot, 1), locs(cur_plot, 2), 'o', 'markersize', 5, 'color', 'blue');
        else
            if nargin == 2
                hold on; plot(locs(cur_plot, 1), locs(cur_plot, 2), 'o', 'markersize', 5, 'color', col);
            else
                hold on; plot(locs(cur_plot, 1), locs(cur_plot, 2), m_type, 'markersize', 5, 'color', col);
            end
        end
    end
    
end