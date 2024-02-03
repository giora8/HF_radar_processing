import os
import numpy as np
from argparse import ArgumentParser
import json
import subprocess
from utils import get_str_ang, extract_tar_folder
# This Python script take .SORT files from the Synology server and generates ascii files containing the spectrum on each
# of the desired angles entered by the user. User enters all desired information from the config json file.


def _get_parameters():
    parser = ArgumentParser()
    parser.add_argument('--json', required=True, help='json of the run')
    return parser.parse_args()


def generate_day_deg(config, station_id, day, angles_arr):
    """
    Function gets .SORT files location on the Synology server and writes .deg ascii files on the Synology server
    :param config: .SORT file location. '/mnt/synology/WERA/data/is1/YYYY'
    :param day: Days in a year which wanted to be evaluated. Example: days_list = ['127', '128', '129']
    :param angles_arr: Angles wanted to be calculated from the .SORT files. Example: angles = np.arange(-12, 13, 1)
    :return: .deg file written in '/mnt/synology/WERA/raw_spectrum'
    """
    WERA_fortran_path = config["SORT2asc"]["Plott_WERA_Sort_RCs_Beam_ASCII path"]
    target_path = config["sys_config"]["SORT_ascii_path"]
    utils_txt_file = config["SORT2asc"]["utils_txt_path"]
    day_root_path = os.path.join(config["sys_config"]["SORT_root_path"], station_id, "raw", day[0:4], day[4:])

    file_list = os.listdir(day_root_path)
    if any(file.endswith('.tar.gz') for file in file_list):
        file_list = extract_tar_folder(day_root_path)
    file_list_generator = (x for x in file_list)
    os.chdir(day_root_path)
    for num, cur_file in enumerate(file_list_generator):
        if cur_file.endswith('.SORT'):
            day_target_path = os.path.join(target_path, day)
            os.makedirs(day_target_path, exist_ok=True)
            for ang in angles_arr:
                cur_ang = np.array2string(ang)
                target_file = os.path.join(day_target_path, cur_file.rsplit('.', 1)[0] + '_' + cur_ang + 'deg.asc')
                if not os.path.isfile(target_file):  # operate calculation only for files that are not exist
                    f = open(utils_txt_file, "w")
                    f.write('X\n')

                    f.write(cur_ang + '\n')
                    f.write('N\n')
                    f.close()
                    cur_ang = get_str_ang(ang, cur_ang)
                    ascii_additional_name = cur_file.rsplit('.', 1)[0] + '_' + cur_ang + 'deg.asc'
                    optional_filename = day_target_path + ascii_additional_name
                    if not os.path.isfile(optional_filename):
                        gen_deg_command = WERA_fortran_path + ' ' + cur_file + ' < ' + utils_txt_file
                        os.system(gen_deg_command)
                        current_asc_location = os.path.join(day_root_path, ascii_additional_name)
                        target_asc_location = os.path.join(day_target_path, ascii_additional_name)

                        subprocess.run(['mv', current_asc_location, target_asc_location])


def WeraSORT2ascii(config):
    run_config = config["SORT2asc"]
    station_name = run_config["station"]
    station_id = config["sys_config"][station_name]["name"]

    days_to_run = run_config["period_to_extract"]
    angles_to_run = run_config["angles_to_extract"]

    every_day_to_run = np.arange(days_to_run[0], days_to_run[1]+1)  # TODO: fit to periods that changes year
    every_angle_to_run = np.arange(angles_to_run[0], angles_to_run[1]+1)
    for day in every_day_to_run:
        day_string = str(day)
        generate_day_deg(config, station_id, day_string, every_angle_to_run)


if __name__ == '__main__':
    args = _get_parameters()
    config = json.load(open(args.json))
    WeraSORT2ascii(config)
