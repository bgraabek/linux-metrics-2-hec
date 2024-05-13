#!/bin/sh

# Use mpstat to collect CPU metrics and send them to Falcon LogScale using HEC

. `dirname $0`/config.sh

# ** Explanation of all the 'sed' manipulations **
# Remove first line, then
# remove all lines starting with '/tmpfs, then
# remove all blank lines, then
# add the host name to beginning of string, then
# convert all space sequences to ,

df -k --output=source,fstype,size,used,avail,pcent | \
sed '1,1d' | \
sed '/tmpfs/d' | \
sed 's/%//g' | \
sed "s/^/$HOST /g"| \
sed -r 's/[[:blank:]]+/,/g' | \
awk -F"," '{print "{\"host\":\""$1"\", \"source\":\"linux_diskspace\", \"fields\":{\"#category\":\"linux_metrics\", \"diskDevice\":\""$2"\", \"diskFileSystemType\":\""$3"\", \"diskSize\":"$4", \"diskUsed\":"$5", \"diskAvailable\":"$6", \"diskPctUtil\":"$7"}}"}' | \
/usr/bin/curl $HEC_HOST/api/v1/ingest/hec -X POST -H "Content-Type: text/plain; charset=utf-8" -H "Authorization: Bearer $INGEST_TOKEN" --data-binary @-
