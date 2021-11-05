"""
Script for automatically thresholding a PGM image to make a PBM. Assumes you're photographing a white
piece of paper with black text on it and that the top of the photo is meant to be white.
"""

import sys
import math
import numpy as np
import netpbmfile

input = netpbmfile.imread(sys.argv[1])

# Get the first and last y rows of pixels, split them into x pixel wide groups, and take the minimum
# of every 2y*x pixel grouping. These are our columnar threshold values
y = 20
x = 18

split_width = math.ceil(input.shape[1]/x)
joined = np.concatenate((input[0:y,:], input[-y:,:]))
splits = np.array_split(joined, split_width, 1)
threshold_values = np.min(splits, (1, 2))
threshold_mask = np.kron(threshold_values, np.ones((input.shape[0], x)))
output = np.where(input > threshold_mask, 255, 0)

netpbmfile.imwrite(sys.argv[2], output)
