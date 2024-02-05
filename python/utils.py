import os
import numpy as np
import tarfile
import subprocess


def get_str_ang(ang, init_cur_ang):
    """ get angle value (degrees) as integer and string and return WERA ascii filename for this angle """
    if ang == 0:
        cur_ang = '000'

    else:
        if ang > 0:
            if ang < 10:
                cur_ang = '00' + init_cur_ang
            else:
                cur_ang = '0' + init_cur_ang

        else:

            if np.abs(ang) < 10:
                cur_ang = '-0' + init_cur_ang[1:]
            else:
                cur_ang = init_cur_ang
    return cur_ang


def extract_tar_folder(path):
    """ get directory path and extract all tar.gz file if there are ones. Return list of all extracted files """
    file_list = os.listdir(path)
    file_gen = (x for x in file_list)
    os.chdir(path)
    print('Extracting tar.gz files ...')
    for cur_file in file_gen:
        if cur_file.endswith("tar.gz"):
            tar = tarfile.open(cur_file, "r:gz")
            tar.extractall()
            tar.close()
    # handle tar extraction output
    day_form_path = os.path.basename(path)
    year_from_path = os.path.basename(os.path.dirname(path))
    extracted_files_current_dir = os.path.join(path, day_form_path+year_from_path, "raw")
    extracted_files_target_dir = os.path.join(os.path.dirname(path), "temp")

    subprocess.run(['mv', extracted_files_current_dir, extracted_files_target_dir])
    subprocess.run(['rm', '-rf', day_form_path+year_from_path], check=True)

    subprocess.run(['rm', '-rf', path])
    subprocess.run(['mv', extracted_files_target_dir, path])

    file_list = os.listdir(path)
    print('finish extracting tar.gz files')
    return file_list

def edit_utils_to_ascii(config, angle):
    """ edit the input txt file for the ascii file generation """
    f = open(config["utils_txt_path"], "w")
    f.write('X\n')
    cur_ang = np.array2string(angle)
    f.write(cur_ang + '\n')
    f.write('N\n')
    f.close()


def edit_utils_txt_to_shortSORT(config):
    """ edit the input txt file for the shortSORT file generation """
    f = open(config["utils_txt_path"], "w")
    short_samples = config["short_samples"]
    shift_samples = config["shift_samples"]
    range_cells = config["num_range_cells"]

    f.write(short_samples + '\n')

    f.write(shift_samples + '\n')
    f.write(range_cells + '\n')
    f.close()


def calculate_ascii_from_SORT(config, cur_ang, input_sort, filename_target):
    """ function that operate WERA FORTRAN code to extract ascii spectrum file """
    if not os.path.isfile(filename_target):
        fortran_command = ["./" + config["SORT2ascii"]["Plott_WERA_Sort_RCs_Beam_ASCII_path"], input_sort]
        os.chdir(config["sys_config"]["root_WERA_fortran_package"])
        with open(config["SORT2ascii"]["utils_txt_path"], 'r') as input_file:
            _ = subprocess.run(fortran_command, stdin=input_file, stdout=subprocess.PIPE,
                               stderr=subprocess.PIPE)
        current_asc_location = input_sort.rsplit('.', 1)[0] + '_' + cur_ang + 'deg' + '.asc'
        subprocess.run(['mv', current_asc_location, filename_target])


def generate_shortSORT_from_single_SORT(config, sort_root_path, target_path):
    """ function that operate WERA FORTRAN code to extract shortSORT from SORT file """
    fortran_command = ["./" + config["SORT2ShortSORT"]["SORT2shortSORT_fortran_path path"], sort_root_path]
    os.chdir(config["sys_config"]["root_WERA_fortran_package"])
    with open(config["utils_txt_path"], 'r') as input_file:
        _ = subprocess.run(fortran_command, stdin=input_file, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    WERA_scropt_output_path = os.path.dirname(sort_root_path) + "shortSORT"
    final_Destination_path = os.path.join(target_path, "shortSORT", os.path.basename(target_path))
    subprocess.run(['mv', WERA_scropt_output_path, final_Destination_path])