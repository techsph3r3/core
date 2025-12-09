#!/bin/bash
#CybatiWorks-1 Engineering FTP Traffic Generator
ftp -in 10.0.11.10 << SCRIPTEND
user anonymous engineering@cybatiworks.local
binary
mget PASSWORD.RSS
SCRIPTEND
