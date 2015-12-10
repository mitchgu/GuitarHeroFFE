import os, sys
import argparse

if os.getuid() != 0:
    print "Please run as root"
    sys.exit()

parser = argparse.ArgumentParser(description='Dump blocks of a disk into a file')
parser.add_argument('blocks', metavar='N', type=int, nargs='+',
                   help='start blocks at which to dump data')
parser.add_argument('-f', '--folder', type=str, default="sd_dump",
                   help='which folder to write to')
parser.add_argument('-l', '--length', type=int, default=1,
                   help='length in blocks of each dump')
parser.add_argument('-s', '--blocksize', type=int, default=512,
                   help='blocksize in bytes')
parser.add_argument('-d', '--disk', type=str, default="disk2",
                   help='which disk to read from')

args = parser.parse_args()

os.seteuid(501)

if not os.path.exists(args.folder):
    os.makedirs(args.folder)

with open('/dev/'+args.disk,"rb") as disk:
    for block in args.blocks:
        disk.seek(block*args.blocksize)
        data = disk.read(args.length*args.blocksize)
        filename = args.folder + "_" + str(block) + ".bit"
        filename_full = "/".join([args.folder, filename])
        with open(filename_full, 'w') as bitfile:
            bitfile.write(data)