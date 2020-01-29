#!/bin/bash


top -b -d 30 -n 43200 >> /var/tmp/AMR15912871i/top.txt &

sar -n DEV 30 43200 >> /var/tmp/AMR15912871i/sar_nics.txt &

sar -q 30 43200 >> /var/tmp/AMR15912871i/sar_load.txt &

sar -r 30 43200 >> /var/tmp/AMR15912871i/sar_memory.txt &

sar -c 30 43200 >> /var/tmp/AMR15912871i/sar_process.txt &

sar -P ALL 30 43200 >> /var/tmp/AMR15912871i/sar_processors.txt &

iostat -tdmx 30 43200 >> /var/tmp/AMR15912871i/iostat.txt &

vmstat 30 43200 >> /var/tmp/AMR15912871i/vmstat.txt &
