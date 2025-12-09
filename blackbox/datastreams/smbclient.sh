#!/bin/bash
#CybatiWorks-1 Traffic Generator
while true
do
        rm engineering_invoice.docx
        smbget -w CYBATIWORKS -a smb://10.0.11.10/ftpshare/engineering_invoice.docx
	sleep 60
        rm CybatiWorks_1_Desktop.png
        smbget -w CYBATIWORKS -a smb://n16.cybatiworks.local/ftpshare/CybatiWorks_1_Desktop.png
        sleep 60
done

