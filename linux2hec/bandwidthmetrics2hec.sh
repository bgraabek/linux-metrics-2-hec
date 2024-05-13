#!/bin/sh

# Use sar to collect network bandwidth metrics and send to Falcon LogScale using HEC

. `dirname $0`/config.sh

# ** Explanation of all the 'sed' manipulations **
# Remove first 3 lines, then
# remove all lines starting with 'Average, then
# remove all blank lines, then
# add the host name to beginning of string, then
# convert all space sequences to ,

export S_TIME_FORMAT=ISO
sar -n DEV 1 1 | \
sed '1,3d' | \
sed '/^Average/d' | \
sed '/lo/d' | \
sed '/^$/d' | \
sed "s/^/$HOST /g" | \
sed -r 's/[[:blank:]]+/,/g' | \
awk -F"," '{print "{\"host\":\""$1"\", \"source\":\"linux_bandwidth\", \"fields\":{\"#category\":\"linux_metrics\", \"interface\":\""$3"\", \"rxpckPs\":"$4", \"txpckPs\":"$5", \"rxkBPs\":"$6", \"txkBPs\":"$7", \"rxMulticastPs\":"$10", \"pctIfUtil\":"$11"}}"}' | \
/usr/bin/curl $HEC_HOST/api/v1/ingest/hec -X POST -H "Content-Type: text/plain; charset=utf-8" -H "Authorization: Bearer $INGEST_TOKEN" --data-binary @-
