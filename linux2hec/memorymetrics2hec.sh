#!/bin/sh

# Use 'free' to collect memory metrics and send them to Falcon LogScale using HEC

. `dirname $0`/config.sh

export S_TIME_FORMAT=ISO

free -m -w | xargs | awk '{print"{\"host\":\"'"$HOST"'\", \"source\":\"linux_rammetrics\", \"fields\":{\"#category\":\"linux_metrics\", \"ram"$1"\": "$9",\"ram"$2"\": "$10",\"ram"$3"\": "$11",\"ram"$4"\": "$12",\"ram"$5"\": "$13",\"ram"$6"\": "$14",\"ram"$7"\": "$15", \"swap"$1"\": "$17",\"swap"$2"\": "$18",\"swap"$3"\": "$19"}}"}' |\
/usr/bin/curl $HEC_HOST/api/v1/ingest/hec -X POST -H "Content-Type: text/plain; charset=utf-8" -H "Authorization: Bearer $INGEST_TOKEN" --data-binary @-
