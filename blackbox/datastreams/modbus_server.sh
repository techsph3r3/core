#!/bin/bash
#CybatiWorks-1 Blackbox Attack Server
CORE_SESSION=$(ls -d /tmp/pycore.* | sed 's/[^0-9]*//g')
vcmd -c /tmp/pycore.$CORE_SESSION/n36 -- /opt/CybatiWorks/Labs/blackbox/datastreams/tcp_sync_server.pyc &
