import os
from datetime import datetime
import numpy as np
import tarfile

# This Python script take .SORT files from the Synology server and generates shortSORT files.
# User enters station, year, day and hour and parameters. Files automatically make the desired shortSORT files
# in new folders according to the said parameters. the script is also compatible with .tar files.

 
def generateshortSort_from_sort(sort_fname, shortSort_path, year, day, hour):
    date = year + day
    if not os.path.isdir(shortSort_path + '/' + date):
        os.mkdir(shortSort_path + '/' + date)
        shortSort_path = shortSort_path + '/' + date
    else:
        shortSort_path = shortSort_path + '/' + date

    if not os.path.isdir(shortSort_path + '/shortSORT_' + hour):
        command = './wera_sort_to_shortsort ' + sort_fname + ' < /home/wera/HF_ADCP_comparison/input_shortSort.txt'
        os.chdir('/home/wera/Fortran')
        os.system(command)
        transfer_command = 'mv ' + sort_fname[:-20] + 'shortSORT ' + shortSort_path + '/shortSORT_' + hour
        os.system(transfer_command)

    """if not os.path.isdir(shortSort_path + '/shortSORT_' + hour):
        hour_str = hour
    else:
        hour_str = hour + '_' + datetime.now().strftime("%H:%M:%S")

    changeName_command = 'mv ' + shortSort_path + '/shortSORT ' + shortSort_path + '/' + hour_str
    os.system(changeName_command)"""

def tar_check(list):
    """
Function gets a file list in a given day, and checks if there are any tar type files.
    :return: True if there are at least one tar file in list. Otherwise, return False.
    :param list:
    :return:
    """
    flag = False
    for l in list:
        if l.endswith("tar.gz"):
            flag = True
    return flag


def evaluate_shortSort_from_sort(h_dict, hours, days, input_file_path, target_path, station , year):

    for day in days:
        for hour in hours:
            full_path = input_file_path + '/' + day
            file_list = os.listdir(full_path)
            # if file_list[0].endswith("tar.gz"):
            if tar_check(file_list):
                file_list = extract_tar_folder(full_path)

            cur_sort_fname = input_file_path + '/' + day + '/' + year + day + h_dict[hour] + '_' + station + '.SORT'
            generateshortSort_from_sort(cur_sort_fname, target_path, year, day, h_dict[hour])


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
    os.system(mv_command) # move to temp folder
    os.system(rm_command) # remove folder exp: 2020002
    rm_tar = 'rm -rf ' + path

    mv_end = 'mv ' + path[:-3] + 'temp ' + path
    os.system(rm_tar)
    os.system(mv_end)

    file_list = os.listdir(path)
    print('finish extracting tar.gz files')
    return file_list


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

    station_id = 'is1'  # is1: Ashkelon is2: Ashdod
    year = '2021'
    days_list = ['102']
    hours_list = np.arange(5, 10)

    short_samples = '512'
    shift_samples = '512'
    range_cells = '50'

    f = open("/home/wera/HF_ADCP_comparison/input_shortSort.txt", "w")
    f.write(short_samples + '\n')

    f.write(shift_samples + '\n')
    f.write(range_cells + '\n')
    f.close()

    basic_sort_path = '/mnt/synology/WERA/data/' + station_id + '/raw/' + year  # basic path the days will be taken from
    basic_short_sort_path = '/mnt/synology/WERA/data/' + station_id + '/shortSORT'
    new_dir_name = '/short_' + short_samples + '_shift_' + shift_samples + '_range_' + range_cells
    target_path = basic_short_sort_path + new_dir_name
    new_dir_command = 'mkdir ' + target_path
    if not os.path.isdir(target_path):
        os.system(new_dir_command)


    #days_list = ['043', '044', '045', '046']  # days to analyze oil spil
    # hours_list = np.arange(0, 72)  # full day
    evaluate_shortSort_from_sort(hours_dictionary, hours_list, days_list, basic_sort_path, target_path, station_id, year)
