
import os
import numpy as np
# This Python script take .shortSORT files from the Synology server and generates ascii files containing the spectrum on each
# of the desired angles entered by the user. User enters both days in a year and angles. Files automatically transfer to
# destination on the Synology server: /mnt/synology/WERA/internal_waves/angle_to_shortSort


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


def creat_angFolder(target_path, year, day, hour, sort_fname, rfi_fname):

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


def generate_ang_from_sort(input_sort, target_path, angle, year, day, hour, station_id):

    f = open("/home/wera/HF_ADCP_comparison/input.txt", "w")
    f.write('X\n')
    cur_ang = np.array2string(angle)
    f.write(cur_ang + '\n')
    f.write('N\n')
    f.close()

    new_target_path = target_path + '/' + param_name
    if not os.path.isdir(new_target_path):
        os.mkdir(new_target_path)
    if not os.path.isdir(new_target_path + '/' + station_id):
        os.mkdir(new_target_path + '/' + station_id)
    if not os.path.isdir(new_target_path + '/' + station_id + '/' + year + day):
        os.mkdir(new_target_path + '/' + station_id + '/' + year + day)
    updated_target_path = new_target_path + '/' + station_id + '/' + year + day
    cur_ang = get_str_ang(np.array(angle), cur_ang)

    filename_target = updated_target_path + '/' + input_sort[-22:-5] + '_' + cur_ang + 'deg' + '.asc'
    if not os.path.isfile(filename_target):
        command = './Plott_WERA_Sort_RCs_Beam_ASCII ' + input_sort + ' < /home/wera/HF_ADCP_comparison/input.txt'
        os.chdir('/home/wera/Fortran')
        os.system(command)

        transfer_command = 'mv ' + input_sort[:-5] + '_' + cur_ang + 'deg' + '.asc ' + updated_target_path + '/'
        os.system(transfer_command)


def generate_day_deg(sort_path, deg_path, param_name, hours_dict, days_list, year, hours, angles, station_id):
    """
    Function gets .SORT files location on the Synology server and writes .deg ascii files on the Synology server
    :param sort_path: .SORT file location. '/mnt/synology/WERA/data/is1/YYYY'
    :param days_list: Days in a year which wanted to be evaluated. Example: days_list = ['127', '128', '129']
    :param angles: Angles wanted to be calculated from the .SORT files. Example: angles = np.arange(-12, 13, 1)
    :return: .deg file written in '/mnt/synology/WERA/raw_spectrum'
    """
    command = '/home/wera/Fortran/Plott_WERA_Sort_RCs_Beam_ASCII '

    for day in days_list:
        flag_open_folder = True  # No longer transfer the first SORT and RFI files
        for hour in hours:
            cur_hour = hours_dict[hour]
            full_path = sort_path + '/' + param_name + '/' + year + day + '/shortSORT_' + cur_hour
            file_list = os.listdir(full_path)
            file_list_generator = (x for x in file_list)
            os.chdir(full_path)
            for num, cur_file in enumerate(file_list_generator):
                if cur_file.endswith('.SORT'):
                    if not flag_open_folder:
                        sort_fname = full_path + '/' + cur_file
                        rfi_fname = full_path + '/' + cur_file[:-4] + 'RFI'
                        deg_path = creat_angFolder(deg_path, year, day, cur_hour, sort_fname, rfi_fname)
                        flag_open_folder = True
                    for ang in angles:
                        generate_ang_from_sort(full_path + '/' + cur_file, deg_path, ang, year, day, cur_hour, station_id)


if __name__ == '__main__':

    hours_dictionary = {0: '0000', 1: '0020', 2: '0040', 3: '0100', 4: '0120', 5: '0140', 6: '0200', 7: '0220',
                        8: '0240', 9: '0300', 10: '0320', 11: '0340', 12: '0400', 13: '0420', 14: '0440', 15: '0500',
                        16: '0520', 17: '0540', 18: '0600', 19: '0620', 20: '0640', 21: '0700', 22: '0720', 23: '0740',
                        24: '0800', 25: '0820', 26: '0840', 27: '0900', 28: '0920', 29: '0940', 30: '1000', 31: '1020',
                        32: '1040', 33: '1100', 34: '1120', 35: '1140', 36: '1200', 37: '1220', 38: '1240', 39: '1300',
                        40: '1320', 41: '1340', 42: '1400', 43: '1420', 44: '1440', 45: '1500', 46: '1520', 47: '1540',
                        48: '1600', 49: '1620', 50: '1640', 51: '1700', 52: '1720', 53: '1740', 54: '1800', 55: '1820',
                        56: '1840', 57: '1900', 58: '1920', 59: '1940', 60: '2000', 61: '2020', 62: '2040', 63: '2100',
                        64: '2120', 65: '2140', 66: '2200', 67: '2220', 68: '2240', 69: '2300', 70: '2320', 71: '2340'}

    # hours_list = np.arange(0, 72)  # full day
    year = '2021'
    station_id = 'is1'
    hours_list = np.arange(0, 10)
    days_list = ['102']  # days to analyze
    angles = np.arange(-3, 6, 1)  # angles to calculate

    short_samples = '512'
    shift_samples = '512'
    range_cells = '50'
    param_name = 'short_' + short_samples + '_shift_' + shift_samples + '_range_' + range_cells

    basic_sort_path = '/mnt/synology/WERA/data/' + station_id + '/shortSORT'
    deg_target_path = '/mnt/synology/WERA/radials_spectrum_shortSort'

    generate_day_deg(basic_sort_path, deg_target_path, param_name, hours_dictionary, days_list, year, hours_list, angles, station_id)
