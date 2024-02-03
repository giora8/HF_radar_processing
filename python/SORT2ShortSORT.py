import os
import numpy as np
import tarfile
from argparse import ArgumentParser
import json
import subprocess
from hours_dict import hours_dictionary
from utils import get_str_ang, extract_tar_folder


def _get_parameters():
    parser = ArgumentParser()
    parser.add_argument('--json', required=True, help='json of the run')
    return parser.parse_args()

def generate_shortSORT_from_single_SORT():
    pass

def SORT2ShortSORT(config):
    pass


if __name__ == '__main__':
    args = _get_parameters()
    config = json.load(open(args.json))
    SORT2ShortSORT(config)
