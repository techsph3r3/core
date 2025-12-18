#!/bin/sh
radartool usenol 0
radartool dfsdebug 0
dmesg -c
watch -n 1 dmesg
