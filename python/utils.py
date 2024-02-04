import os
import numpy as np
import tarfile
import subprocess


def get_str_ang(ang, init_cur_ang):
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


def create_angFolder(target_path, year, day, hour, sort_fname, rfi_fname):

    if not os.path.isdir(target_path + '/' + year):
        os.mkdir(target_path + '/' + year)
        target_path = target_path + '/' + year
    else:
        target_path = target_path + '/' + year

    if not os.path.isdir(target_path + '/' + day):
        os.mkdir(target_path + '/' + day)
        target_path = target_path + '/' + day
    else:
        target_path = target_path + '/' + day

    if not os.path.isdir(target_path + '/' + hour):
        os.mkdir(target_path + '/' + hour)
        target_path = target_path + '/' + hour
    else:
        target_path = target_path + '/' + hour

    command = 'cp ' + sort_fname + ' ' + target_path
    os.system(command)

    command = 'cp ' + rfi_fname + ' ' + target_path
    os.system(command)

    return target_path


def extract_tar_folder(path):

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


def edit_utils_txt_to_shortSORT(config):
    f = open(config["utils_txt_path"], "w")
    short_samples = config["short_samples"]
    shift_samples = config["shift_samples"]
    range_cells = config["num_range_cells"]

    f.write(short_samples + '\n')

    f.write(shift_samples + '\n')
    f.write(range_cells + '\n')
    f.close()