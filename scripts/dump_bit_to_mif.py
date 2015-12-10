import sys, os
import argparse
from array import array
import numpy as np
import matplotlib.pyplot as plt
from PIL import Image

parser = argparse.ArgumentParser(description='Read a sd dump and write a mif')
parser.add_argument('folder', metavar='F', type=str,
                   help='Folder with bitfiles')
parser.add_argument("-g", "--graph", action="store_true", default=False, help="Plot a histogram")

args = parser.parse_args()


files = ["/".join([args.folder, f]) for f in os.listdir(args.folder) if f.endswith(".bit")]

total_data = np.zeros((1024,len(files)))

for idx, bitfile in enumerate(files):
    with open(bitfile, "rb") as f:
        data = array("H", f.read())
    data.byteswap()
    total_data[:,idx] = data
means = np.round(np.mean(total_data, axis=1)).astype(int)
#means[:72] = np.zeros(72)
norm = int(round(np.linalg.norm(means)))


MIF_LOCATION = "/".join([args.folder, args.folder + ".mif"])
norm_LOCATION = "/".join([args.folder, args.folder + "_norm.mif"])
with open(MIF_LOCATION, "w") as mif:
    for m in means[:-1]:
        mif.write(format(m, "016b"))
        mif.write("\n")
    mif.write(format(means[-1], "016b"))

with open(norm_LOCATION, "w") as normfile:
    normfile.write("21'b" + format(norm, "022b"))

if args.graph: 
    #indices = np.arange(1024)
    #plot = plt.bar(indices, means)
    #plt.show()
    sm = Image.new("RGB", (1024,768))
    for x in xrange(1024):
        for y in xrange(768):
            if (768-y) < means[x]>>7:
                pixel = (255,255,255)
            else: pixel = (0,0,0)
            sm.putpixel((x,y), pixel)
    sm.show()