#!/usr/bin/env python3

import argparse
import re
import subprocess
import sys

parser = argparse.ArgumentParser()
parser.add_argument('--output', required=True)
parser.add_argument('--resolution', required=True)
parser.add_argument('APP')
args = parser.parse_args()

device_context = ''    # track what device's modes we are looking at
modes = []             # keep track of all the devices and modes discovered
current_modes = []     # remember the user's current settings

# Run xrandr and ask it what devices and modes are supported
xrandrinfo = subprocess.Popen('xrandr -q', shell=True, stdout=subprocess.PIPE)
output = xrandrinfo.communicate()[0].decode().split('\n')

for line in output:
    # luckily the various data from xrandr are separated by whitespace...
    foo = line.split()

    # Check to see if the second word in the line indicates a new context
    #  -- if so, keep track of the context of the device we're seeing
    if len(foo) >= 2:  # throw out any weirdly formatted lines
        if foo[1] == 'disconnected':
            # we have a new context, but it should be ignored
            device_context = ''
        if foo[1] == 'connected':
            # we have a new context that we want to test
            device_context = foo[0]
        elif device_context != '':  # we've previously seen a 'connected' dev
            # mode names seem to always be of the format [horiz]x[vert]
            # (there can be non-mode information inside of a device context!)
            if foo[0].find('x') != -1:
                modes.append((device_context, foo[0]))
            # we also want to remember what the current mode is, which xrandr
            # marks with a '*' character, so we can set things back the way
            # we found them at the end:
            if line.find('*') != -1:
                current_modes.append((device_context, foo[0]))

for mode in modes:
    if args.output == mode[0] and args.resolution == mode[1]:
        cmd = 'xrandr --output ' + mode[0] + ' --mode ' + mode[1]
        subprocess.call(cmd, shell=True)
        break
else:
    print('Unable to set mode ' + args.resolution + ' for output ' + args.output)
    sys.exit(1)

subprocess.call(args.APP, shell=True)

# Put things back the way we found them
for mode in current_modes:
    cmd = 'xrandr --output ' + mode[0] + ' --mode ' + mode[1]
    subprocess.call(cmd, shell=True)