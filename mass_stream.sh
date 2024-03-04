#!/bin/bash
NUMBER_OF_STREAMERS=$1

for ((n=0;n<$NUMBER_OF_STREAMERS;n++))
do
 ffmpeg -f dshow -i video="Virtual-Camera" -preset ultrafast -vcodec libx264 -tune zerolatency -b 900k -f mpegts srt://127.0.0.1:1234?streamid=#!::u=bander$n,r=livestream$n,m=publish,t=stream\&transtype=live\&mode=caller\&latency=1000000 &
done

