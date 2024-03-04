#!/bin/bash
#./mass_watch_cloud.sh 10 livestream3
NUMBER_OF_WATCHERS=$1
STREAM_NAME=$2

for ((n=0;n<$NUMBER_OF_WATCHERS;n++))
do
 ffplay -fflags nobuffer -i "srt://34.18.46.60:10081?streamid=#!::u=bander_w$n,r=${STREAM_NAME},m=request,t=stream,s=Session_ID" &
done

