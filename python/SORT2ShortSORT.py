import os
import numpy as np
from argparse import ArgumentParser
import json
import subprocess
from hours_dict import hours_dictionary
from utils import extract_tar_folder, edit_utils_txt_to_shortSORT


def _get_parameters():
    parser = ArgumentParser()
    parser.add_argument('--json', required=True, help='json of the run')
    return parser.parse_args()


def generate_shortSORT_from_single_SORT(config, sort_root_path, target_path):
    fortran_command = ["./" + config["SORT2ShortSORT"]["SORT2shortSORT_fortran_path path"], sort_root_path]
    os.chdir(config["sys_config"]["root_WERA_fortran_package"])
    with open(config["utils_txt_path"], 'r') as input_file:
        _ = subprocess.run(fortran_command, stdin=input_file, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    WERA_scropt_output_path = os.path.dirname(sort_root_path) + "shortSORT"
    final_Destination_path = os.path.join(target_path, "shortSORT", os.path.basename(target_path))
    subprocess.run(['mv', WERA_scropt_output_path, final_Destination_path])


def SORT2ShortSORT(config):

    run_config = config["SORT2ShortSORT"]
    params_config = run_config["short_params"]
    station_name = run_config["station"]
    station_id = config["sys_config"][station_name]["name"]

    days_to_run = run_config["period_to_extract"]
    hours_to_run = run_config["hours_to_extract"]
    every_hour_to_run = np.arange(hours_to_run[0]-1, hours_to_run[1])
    every_day_to_run = np.arange(days_to_run[0], days_to_run[1] + 1)  # TODO: fit to periods that changes year

    SORT_root_path = os.path.join(config["sys_config"]["SORT_root_path"], station_id, "raw")
    shortSORT_root_path = os.path.join(config["sys_config"]["SORT_root_path"], station_id, "shortSORT")
    params_path = os.path.join(shortSORT_root_path, str(params_config["short_samples"]) + '_shift_' + str(params_config["shift_samples"]) + '_range_' + str(params_config["num_range_cells"]))
    edit_utils_txt_to_shortSORT(run_config)
    os.makedirs(params_path, exist_ok=True)

    for day in every_day_to_run:
        day_string = str(day)
        sort_root_path = os.path.join(SORT_root_path, day_string[0:4], day_string[4:])

        file_list = os.listdir(sort_root_path)
        if any(file.endswith('.tar.gz') for file in file_list):
            _ = extract_tar_folder(sort_root_path)

        for hour in every_hour_to_run:
            hour_string = hours_dictionary[hour]
            hour_SORT_root_path = os.path.join(sort_root_path, day_string + hour_string + "_" + station_id + ".SORT")
            date_target_path = os.path.join(params_path, day)
            os.makedirs(date_target_path, exist_ok=True)
            hour_target_path = os.path.join(date_target_path, "shortSORT_", hour_string)
            if not os.path.isdir(hour_target_path):
                generate_shortSORT_from_single_SORT(config, hour_SORT_root_path, hour_target_path)


if __name__ == '__main__':
    args = _get_parameters()
    config = json.load(open(args.json))
    SORT2ShortSORT(config)
