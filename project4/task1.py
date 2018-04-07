#!/usr/bin/env python3

import sys
import os
import numpy
import numpy.linalg
import scipy.misc

def getOutputPngName(path, rank):
    filename, ext = os.path.splitext(path)
    return filename + '.' + str(rank) + '.png'

def getOutputNpyName(path, rank):
    filename, ext = os.path.splitext(path)
    return filename + '.' + str(rank) + '.npy'

if len(sys.argv) < 3:
    sys.exit('usage: task1.py <PNG inputFile> <rank>')

inputfile = sys.argv[1]
rank = int(sys.argv[2])
outputpng = getOutputPngName(inputfile, rank)
outputnpy = getOutputNpyName(inputfile, rank)

#
# TODO: The current code just prints out what it is supposed to to
#       Replace the print statement wth your code
#
# print("This program should read %s file, perform rank %d approximation, and save the results in %s and %s files." % (inputfile, rank, outputpng, outputnpy))
imageMatrix = scipy.misc.imread(inputfile, 0)

# Perform SVD (U, V = unitary matrices, s = singular Values)
U, s, V = numpy.linalg.svd(imageMatrix)
# print(U.shape, V.shape, s.shape) # (m,n) = (row,col)

# Keep only top-k (k="rank") entries in the SVD decomposed matrices
U_topk = U[:,:rank]    # [row, col] - slice by col
V_topk = V[:rank,:]		 # Transposed - slice by row
s_topk = s[:rank]			 # Reduce dim to rank
# print(U_topk.shape, V_topk.shape, s_topk.shape)

# Diagonalize s(array) into a (rank x rank) matrix
s_topk_diag = numpy.diag(s_topk)
# print(s_topk_diag.shape)

new_a = numpy.dot(U_topk, numpy.dot(s_topk_diag, V_topk))
# print(new_a)

# Save the approximated array as
# 1. binary array file to outputnpy
numpy.save(outputnpy, new_a)
# 2. png file to outputpng
scipy.misc.imsave(outputpng, new_a)
