#!/bin/bash
NUMBER_OF_STREAMERS=$1

for ((n=0;n<$NUMBER_OF_STREAMERS;n++))
do
 ffmpeg -f dshow -i -stream-loop 1 -i test.webm -preset ultrafast -vcodec libx264 -tune zerolatency -b 900k -f mpegts srt://34.18.0.215:10081?streamid=#!::u=bander$n,r=livestream$n,m=publish,t=stream\&transtype=live\&mode=caller\&latency=1000000 &
done

