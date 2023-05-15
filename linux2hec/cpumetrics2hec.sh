#!/bin/sh

# Use mpstat to collect CPU metrics and send them to Falcon LogScale using HEC
# host, ts, CPU, pctUsr,pctNice, pctSys, pctIowait, pctIrq, pctSoft, pctSteal, pctGuest, pctGnice, pctIdle

. `dirname $0`/config.sh

# ** Explanation of all the 'sed' manipulations **
# Remove first 3 lines, then
# remove all lines starting with 'Average, then
# remove all blank lines, then
# add the host name to beginning of string, then
# convert all space sequences to ,

export S_TIME_FORMAT=ISO
mpstat -P ALL 1 1 | \
sed '1,3d' | \
sed '/^Average/d' | \
sed '/^$/d' | \
sed "s/^/$HOST /g" | \
sed -r 's/[[:blank:]]+/,/g' | \
awk -F"," '{print "{\"host\":\""$1"\", \"source\":\"linux_cpumetrics\", \"fields\":{\"#category\":\"linux_metrics\", \"CPU\":\""$3"\", \"pctUsr\":"$4", \"pctNice\":"$5", \"pctSys\":"$6", \"pctIowait\":"$7", \"pctIrq\":"$8", \"pctSoft\":"$9", \"pctSteal\":"$10", \"pctGuest\":"$11", \"pctGnice\":"$12", \"pctIdle\":"$13"}}"}' | \
while read line; do \
  /usr/bin/curl $HEC_HOST/api/v1/ingest/hec -X POST -H "Content-Type: text/plain; charset=utf-8" -H "Authorization: Bearer $INGEST_TOKEN" --data "$line"; \
done