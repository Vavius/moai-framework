#!/usr/bin/env python

import sys, os, argparse

from PIL import Image

def extractBorder(image):

    pass


def applyBorder(image, border):

    pass


def applyScale(image, scale):

    pass


def processImages(in_dir, out_dir, scale):
    
    pass


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('-s', '--scale', required = False, choices=['2', '4'], help = "Input images scale", default='2')
    parser.add_argument('-o', '--out', help="Output directory. Subfolders will be created: sd, hd, ipad-hd", default="output")
    parser.add_argument('dir', help="Input directory")
    args = parser.parse_args()

    initial_scale = float(args.scale)
    output_root = args.out
    input_dir = args.dir

    scale = 1.0
    while initial_scale >= 1:
        initial_scale, scale = initial_scale / 2, scale / 2
        processImages(input_dir, output_root, scale)
    

if __name__ == '__main__':
    main()
