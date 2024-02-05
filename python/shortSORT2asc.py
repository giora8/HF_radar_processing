import os
import numpy as np
from argparse import ArgumentParser
import json
import subprocess
from hours_dict import hours_dictionary
from utils import edit_utils_to_ascii, get_str_ang, calculate_ascii_from_SORT, extract_tar_folder


def _get_parameters():
    parser = ArgumentParser()
    parser.add_argument('--json', required=True, help='json of the run')
    return parser.parse_args()


def calculate_ascii_for_each_ang(config, angles_arr, input_sort, output_target_path):
    for ang in angles_arr:
        cur_ang = np.array2string(ang)
        cur_ang = get_str_ang(ang, cur_ang)
        edit_utils_to_ascii(config, cur_ang)
        filename_target = os.path.join(output_target_path, os.path.basename(input_sort).rsplit('.', 1)[0],
                                       '_' + cur_ang + 'deg' + '.asc')
        calculate_ascii_from_SORT(config, cur_ang, input_sort, filename_target)


def shortSORT2asc(config):
    run_config = config["ShortSORT2asc"]
    params_config = run_config["short_params"]
    station_name = run_config["station"]
    station_id = config["sys_config"][station_name]["name"]

    days_to_run = run_config["period_to_extract"]
    hours_to_run = run_config["hours_to_extract"]
    angles_to_run = run_config["angles_to_extract"]

    every_day_to_run = np.arange(days_to_run[0], days_to_run[1] + 1)  # TODO: fit to periods that changes year
    every_hour_to_run = np.arange(hours_to_run[0] - 1, hours_to_run[1])
    every_angle_to_run = np.arange(angles_to_run[0], angles_to_run[1] + 1)

    original_sort_path = os.path.join(config["sys_config"]["SORT_root_path"], station_id, "raw")
    input_sort_path = os.path.join(config["sys_config"]["SORT_root_path"], station_id, "shortSORT")
    shortSORT_root_path = os.path.join(config["sys_config"]["short_SORT_ascii_path"])
    params_path_input_sort = os.path.join(input_sort_path, str(params_config["short_samples"]) + '_shift_' + str(
        params_config["shift_samples"]) + '_range_' + str(params_config["num_range_cells"]), station_id)
    params_path = os.path.join(shortSORT_root_path, str(params_config["short_samples"]) + '_shift_' + str(params_config["shift_samples"]) + '_range_' + str(params_config["num_range_cells"]), station_id)

    for day in every_day_to_run:
        day_string = str(day)
        target_ascii_path = os.path.join(params_path, day_string)
        os.makedirs(target_ascii_path, exist_ok=True)
        for ii, hour in enumerate(every_hour_to_run):
            cur_hour = hours_dictionary[hour]
            input_sort_path = os.path.join(params_path_input_sort, day_string,
                                           "shortSORT_" + cur_hour + day_string + cur_hour + '_' + station_id + ".SORT")
            calculate_ascii_from_SORT(config, every_angle_to_run, input_sort_path, target_ascii_path)


if __name__ == '__main__':
    args = _get_parameters()
    config = json.load(open(args.json))
    shortSORT2asc(config)
