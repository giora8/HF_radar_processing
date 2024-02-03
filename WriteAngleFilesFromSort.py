import os
import numpy as np
import tarfile
from argparse import ArgumentParser
# This Python script take .SORT files from the Synology server and generates ascii files containing the spectrum on each
# of the desired angles entered by the user. User enters both days in a year and angles. Files automatically transfer to
# destination on the Synology server: /mnt/synology/WERA/raw_spectrum


def _get_parameters():
    parser = ArgumentParser()
    parser.add_argument('--json', required=True, help='json of the run')
    return parser.parse_args()


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
    mv_command = 'mv ' + path + '/' + path[-8:-4] + path[-3:] + '/raw ' + path[:-3] + 'temp'
    rm_command = 'rm -rf ' + path[-8:-4] + path[-3:]
    os.system(mv_command)
    os.system(rm_command)
    rm_tar = 'rm -rf ' + path

    mv_end = 'mv ' + path[:-3] + 'temp ' + path
    os.system(rm_tar)
    os.system(mv_end)

    file_list = os.listdir(path)
    print('finish extracting tar.gz files')
    return file_list



def generate_day_deg(sort_path, days_list, angles):
    """
    Function gets .SORT files location on the Synology server and writes .deg ascii files on the Synology server
    :param sort_path: .SORT file location. '/mnt/synology/WERA/data/is1/YYYY'
    :param days_list: Days in a year which wanted to be evaluated. Example: days_list = ['127', '128', '129']
    :param angles: Angles wanted to be calculated from the .SORT files. Example: angles = np.arange(-12, 13, 1)
    :return: .deg file written in '/mnt/synology/WERA/raw_spectrum'
    """
    command = '/home/wera/Fortran/Plott_WERA_Sort_RCs_Beam_ASCII '
    for day in days_list:
        flag_open_folder = False
        full_path = sort_path + day
        file_list = os.listdir(full_path)
        if file_list[0].endswith("tar.gz"):
            file_list = extract_tar_folder(full_path)
        file_list_generator = (x for x in file_list)
        os.chdir(full_path)
        for num, cur_file in enumerate(file_list_generator):
            if cur_file.endswith('.SORT'):
                if not flag_open_folder:
                    new_path = '/mnt/synology/WERA/radials_spectrum/' + cur_file[0:4]+day + '/'
                    os.system('mkdir ' + new_path)
                    flag_open_folder = True
                for ang in angles:
                    cur_ang = np.array2string(ang)
                    target_file = new_path + cur_file[:-5] + '_' + cur_ang + 'deg.asc'
                    if not os.path.isfile(target_file):  # operate calculation only for files that are not exist
                        f = open("/home/wera/HF_ADCP_comparison/input.txt", "w")
                        f.write('X\n')

                        f.write(cur_ang + '\n')
                        f.write('N\n')
                        f.close()
                        cur_ang = get_str_ang(ang, cur_ang)
                        optional_filename = new_path + cur_file[:-5] + '_' + cur_ang + 'deg.asc'
                        if not os.path.isfile(optional_filename):
                            gen_deg_command = command + ' ' + cur_file + ' < /home/wera/HF_ADCP_comparison/input.txt'
                            os.system(gen_deg_command)

                            transfer_command = 'mv ' + full_path + '/' + cur_file[:-5] + '_' + cur_ang + 'deg.asc ' + new_path + cur_file[:-5] + '_' + cur_ang + 'deg.asc'

                            os.system(transfer_command)


if __name__ == '__main__':
    station_id = 'is1'  # is1: Ashkelon is2: Ashdod
    year = '2021'
    days_list = ['102']  # days to analyze
    angles = np.arange(-3, 6, 1)  # angles to calculate
    basic_sort_path = '/mnt/synology/WERA/data/' + station_id + '/raw/' + year + '/'  # basic path the the days will be taken from

    generate_day_deg(basic_sort_path, days_list, angles)
