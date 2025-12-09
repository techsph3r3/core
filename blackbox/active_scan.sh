#!/bin/bash
#CybatiWorks-1 Blackbox Active Scan Dialog
zenity --info --text "WARNING\n\nActively scanning live Industrial networks may cause erractic behavior.\nIndustrial networks rely upon predictable access to IO information and scan times.\nNetwork traffic and interacting with TCP/UDP ports can place additional load on the CPU.\nDo not perform active scanning in any environment without rigorous testing.\n\nYou are authorized to perform active scanning in this test environment.\n\nZenmap will be launched to begin scanning the CybatiWorks Blackbox industrial network subnet.\nOnce Zenmap is launched you will need to click SCAN to begin.\nZenmap offers several features for you to explore." --no-wrap
zenmap -v -t 172.16.192.0/24
